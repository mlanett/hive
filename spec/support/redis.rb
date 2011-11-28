# -*- encoding: utf-8 -*-

require "redis"               # required by RedisClient

REDIS = { url: "redis://127.0.0.1:6379/1" }

module RedisClient

  def redis
    @redis ||= begin
      ::Redis.connect(REDIS)
    end
  end

  def with_clean_redis(&block)
    redis.flushall
    yield
  ensure
    redis.flushall
    redis.quit
  end

  def with_default_client( before_default_storage = Hive.default_storage, &block)
    Hive.default_storage = Hive::Redis::Storage.new
    yield
  ensure
    Hive.default_storage = before_default_storage
  end

end # RedisClient
