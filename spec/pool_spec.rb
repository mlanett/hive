# -*- encoding: utf-8 -*-

require "helper"
require "redis"

describe Hive::Pool do

  describe "the name" do

    it "needs a name for a proc" do
      name = "#{ described_class || 'Test' }::#{example.object_id}"
      job  = ->(context) { false }
      expect { pool = Hive::Pool.new( job ) }.to raise_error
      expect { pool = Hive::Pool.new( job, name: name ) }.to_not raise_error
    end

    it "does not need a name for a class" do
      job = TrueJob
      expect { pool = Hive::Pool.new( job ) }.to_not raise_error
    end

  end

  describe "when spawning proceses", redis: true do

    it "should spawn a worker" do
      name    = "#{ described_class || 'Test' }::#{example.description}"
      policy  = { name: name, worker_max_lifetime: 4 }
      job     = ->(context) {}
      storage = Hive::Redis::Storage.new(redis)
      pool    = Hive::Pool.new( job, policy, storage )

      pool.stub(:spawn) {} # must be called at least once

      pool.synchronize
    end

    it "spins up an actual worker" do
      name    = "#{ described_class || 'Test' }::#{example.description}"
      policy  = { name: name, observers: [ [ :log, "/tmp/debug.log" ] ], worker_max_lifetime: 4 }
      factory = ->() { ListenerJob.new() }
      storage = Hive::Redis::Storage.new(redis)
      pool    = Hive::Pool.new( ListenerJob, policy, storage )

      pool.registry.workers.size.should be == 0

      pool.synchronize
      wait_until { pool.registry.workers.size > 0 }
      pool.registry.workers.size.should be > 0
      other = pool.registry.workers.first

      me = Hive::Messager.new storage, my_address: "Pool-me@localhost"
      me.expect(/State/) { |body,message| puts body }
      me.send "State?", to: other
      me.receive
      me.send "Quit", to: other
    end

    it "spins up a worker only once" #do
    #  index   = 0
    #  storage = Hive::Mocks::Storage.new
    #  policy  = Hive::Policy.resolve worker_max_lifetime: 4
    #  pool    = Hive::Pool.new( SpawnWaitQuitJob, policy, storage )
    #  pool.stub(:spawn) {}
    #end

    it "does not spin up the worker twice" #do
    #  policy = Hive::Policy.resolve worker_max_lifetime: 4
    #  pool = Hive::Pool.new( SpawnWaitQuitJob )
    #  pool.synchronize
    #  wait_until { redis.get("SpawnWaitQuitJob").to_i != 0 }
    #  pid_first = redis.get("SpawnWaitQuitJob").to_i
    #
    #  pool.synchronize
    #  wait_until { redis.get("SpawnWaitQuitJob").to_i != pid_first }
    #  redis.get("SpawnWaitQuitJob").to_i.should eq(pid_first)
    #
    #  redis.set("SpawnWaitQuitJob",0)
    #end

    it "should spin up two workers"
    # do
    #  redis.del "Hive::SpecJob"
    #
    #  it = Hive::Pool.new( "Hive::SpecJob", Hive::Policy.resolve( pool_min_workers: 2, worker_max_jobs: 1) )
    #  it.synchronize
    #  wait_until { redis.scard("Hive::SpecJob") == 2 }
    #
    #  redis.scard("Hive::SpecJob").should eq 2
    #  redis.del "Hive::SpecJob"
    #end

  end

  describe "when tracking how long workers run", time: true do

    it "should warn when a worker is running late"

    it "should kill when a worker is running too late"

  end

end
