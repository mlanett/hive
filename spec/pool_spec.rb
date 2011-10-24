# -*- encoding: utf-8 -*-

require "redis"

class Hive::SpecJob
  def call
    redis.sadd "Hive::SpecJob", Process.pid
    false
  end
  def redis
    @redis ||= Redis.connect(REDIS)
  end
end

describe Hive::Pool do
  
  it "should spin up two workers" do
  # redis = Redis.connect(REDIS)
  # redis.del "Hive::SpecJob"
  # it = Hive::Pool.new( "Hive::SpecJob", :pool_min_workers => 2, :worker_max_jobs => 1 )
  # it.synchronize
  # Hive::Idler.wait_until { redis.scard("Hive::SpecJob") == 2 }
  # redis.scard("Hive::SpecJob").must_equal 2
  # redis.del "Hive::SpecJob"
  end

end
