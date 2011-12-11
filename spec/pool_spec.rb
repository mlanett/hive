# -*- encoding: utf-8 -*-

require "helper"
require "redis"

describe Hive::Pool do

  before do
    @name = "#{ described_class || 'Test' }::#{example.description}"
  end

  describe "name" do

    it "needs to be specified for a proc" do
      job  = ->(context) { false }
      expect { pool = Hive::Pool.new( job ) }.to raise_error
      expect { pool = Hive::Pool.new( job, name: @name ) }.to_not raise_error
    end

    it "does not need to be specified for a class" do
      job = TrueJob
      expect { pool = Hive::Pool.new( job ) }.to_not raise_error
    end

  end

  describe "when spawning proceses", redis: true do

    def make_policy( options = {} )
      options = { name: @name, worker_max_lifetime: 10, storage: :redis, observers: [ [ :log, "/tmp/debug.log" ] ] }.merge(options)
      Hive::Policy.resolve(options)
    end

    it "should spawn a worker" do
      job     = ->(context) {}
      pool    = Hive::Pool.new( job, make_policy )

      pool.stub(:spawn) {} # must be called at least once

      pool.synchronize
    end

    it "spins up an actual worker" do
      pool    = Hive::Pool.new( ListenerJob, make_policy )

      pool.registry.workers.size.should be == 0

      pool.synchronize
      wait_until { pool.registry.workers.size > 0 }
      pool.registry.workers.size.should be > 0
      other = pool.registry.workers.first

      pool.rpc.expect(/State/) { |message| puts message.body }
      pool.rpc.send "State?", to: other
      pool.rpc.receive
      pool.rpc.send "Quit", to: other
    end

    it "spins up a worker only once" do
      policy   = make_policy pool_max_workers: 1
      pool     = Hive::Pool.new( ListenerJob, policy )
      registry = pool.registry

      registry.checked_workers( policy ).live.size.should eq(0)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(1)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(1)
    end

    it "should spin up new workers as necessary" do
      policy   = make_policy pool_min_workers: 2, pool_max_workers: 2
      pool     = Hive::Pool.new( ListenerJob, policy )
      registry = pool.registry

      registry.checked_workers( policy ).live.size.should eq(0)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(2)

      first = registry.checked_workers( policy ).live.first
      pool.rpc.send "Quit", to: first
      wait_until { registry.checked_workers( policy ).live.size == 1 }
      registry.checked_workers( policy ).live.size.should eq(1)

#      pool.synchronize
#      registry.checked_workers( policy ).live.size.should eq(1)
    end

    it "spins down workers when there are too many"

  end

  describe "when tracking how long workers run", time: true do

    it "should warn when a worker is running late"

    it "should kill when a worker is running too late"

  end

end
