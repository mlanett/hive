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

    it "should spin up two workers" do
      redis.del "Hive::SpecJob"

      it = Hive::Pool.new( "Hive::SpecJob", Hive::Policy.new(:pool_min_workers => 2, :worker_max_jobs => 1) )
      it.synchronize
      Hive::Idler.wait_until { redis.scard("Hive::SpecJob") == 2 }

      redis.scard("Hive::SpecJob").should eq 2
      redis.del "Hive::SpecJob"
    end

  end

end
