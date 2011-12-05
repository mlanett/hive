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
    redis.client.disconnect # auto connect after fork
    yield
  ensure
    redis.flushall
    redis.quit
  end

end # RedisClient
