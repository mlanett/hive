# -*- encoding: utf-8 -*-

require "helper"
require "redis"

class Hive::SpecJob
  include RedisClient
  def call
    redis.sadd "Hive::SpecJob", Process.pid
    false
  end
end

describe Hive::Pool do

  describe "when spawning proceses", :redis => true do

    it "should spawn a worker" do
      job  = ->(context) {}
      pool = Hive::Pool.new( job, :name => "Test" )

      pool.stub(:spawn) {}

      pool.synchronize
    end

    it "spins up a worker only once" #do
    #  index   = 0
    #  storage = Hive::ProcessStorage.new
    #  policy  = Hive::Policy.resolve :worker_max_lifetime => 10
    #  pool    = Hive::Pool.new( SpawnWaitQuitJob, policy, storage )
    #  pool.stub(:spawn) {}
    #end

    it "does not spin up the worker twice" #do
    #  policy = Hive::Policy.resolve :worker_max_lifetime => 10
    #  pool = Hive::Pool.new( SpawnWaitQuitJob )
    #  pool.synchronize
    #  Hive::Idler.wait_until { redis.get("SpawnWaitQuitJob").to_i != 0 }
    #  pid_first = redis.get("SpawnWaitQuitJob").to_i
    #
    #  pool.synchronize
    #  Hive::Idler.wait_until { redis.get("SpawnWaitQuitJob").to_i != pid_first }
    #  redis.get("SpawnWaitQuitJob").to_i.should eq(pid_first)
    #
    #  redis.set("SpawnWaitQuitJob",0)
    #end

    it "should spin up two workers"
    # do
    #  redis.del "Hive::SpecJob"
    #
    #  it = Hive::Pool.new( "Hive::SpecJob", Hive::Policy.resolve(:pool_min_workers => 2, :worker_max_jobs => 1) )
    #  it.synchronize
    #  Hive::Idler.wait_until { redis.scard("Hive::SpecJob") == 2 }
    #
    #  redis.scard("Hive::SpecJob").should eq 2
    #  redis.del "Hive::SpecJob"
    #end

  end

  describe "when tracking how long workers run", :time => true do

    it "should warn when a worker is running late"

    it "should kill when a worker is running too late"

  end

end
