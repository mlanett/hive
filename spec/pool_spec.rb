# -*- encoding: utf-8 -*-

require "helper"
require "redis"

describe Collective::Pool do

  before do
    @name = "#{ described_class || 'Test' }::#{example.description}"
  end

  describe "name" do

    it "needs to be specified for a proc" do
      job  = ->(context) { false }
      expect { pool = Collective::Pool.new( job ) }.to raise_error
      expect { pool = Collective::Pool.new( job, name: @name ) }.to_not raise_error
    end

    it "does not need to be specified for a class" do
      job = TrueJob
      expect { pool = Collective::Pool.new( job ) }.to_not raise_error
    end

  end

  describe "when spawning proceses", redis: true do

    def make_policy( options = {} )
      options = { name: @name, worker_max_lifetime: 10, storage: :redis, observers: [ [ :log, "/tmp/debug.log" ] ] }.merge(options)
      Collective::Policy.resolve(options)
    end

    it "should spawn a worker" do
      job     = ->(context) {}
      pool    = Collective::Pool.new( job, make_policy )

      pool.stub(:spawn) {} # must be called at least once

      pool.synchronize
    end

    it "spins up an actual worker" do
      pool    = Collective::Pool.new( ListenerJob, make_policy )

      pool.registry.workers.size.should be == 0

      pool.synchronize
      wait_until { pool.registry.workers.size > 0 }
      pool.registry.workers.size.should be > 0
      other = pool.registry.workers.first

      pool.mq.expect(/State/) { |message| puts message.body }
      pool.mq.send "State?", to: other
      pool.mq.receive
      pool.mq.send "Quit", to: other
    end

    it "spins up a worker only once" do
      policy   = make_policy pool_max_workers: 1
      pool     = Collective::Pool.new( ListenerJob, policy )
      registry = pool.registry

      registry.checked_workers( policy ).live.size.should eq(0)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(1)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(1)
    end

    it "should spin up new workers as necessary" do
      policy   = make_policy pool_min_workers: 2, pool_max_workers: 2
      pool     = Collective::Pool.new( ListenerJob, policy )
      registry = pool.registry

      registry.checked_workers( policy ).live.size.should eq(0)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(2)

      first = registry.checked_workers( policy ).live.first
      pool.mq.send "Quit", to: first
      wait_until { registry.checked_workers( policy ).live.size == 1 }
      registry.checked_workers( policy ).live.size.should eq(1)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(2)
    end

    it "spins down workers when there are too many" do
      policy   = make_policy pool_min_workers: 2, pool_max_workers: 2
      pool     = Collective::Pool.new( ListenerJob, policy )
      registry = pool.registry

      registry.checked_workers( policy ).live.size.should eq(0)

      pool.synchronize
      registry.checked_workers( policy ).live.size.should eq(2)

      # create a second pool with its own policy to force quitting
      policy2   = make_policy pool_min_workers: 1, pool_max_workers: 1
      pool2     = Collective::Pool.new( ListenerJob, policy2 )
      pool2.synchronize
      registry.checked_workers( policy ).live.size.should eq(1)
    end

  end

  describe "when tracking how long workers run", time: true do

    it "should warn when a worker is running late"

    it "should kill when a worker is running too late"

  end

end
