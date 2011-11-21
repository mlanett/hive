# -*- encoding: utf-8 -*-

require "redis"
require "timeout"

class Hive::Redis::Storage

  def initialize( redis = nil )
    @redis = redis
  end

  # Simple values

  def put( key, value )
    redis.set( key, value )
  end
  
  def get( key )
    redis.get( key )
  end

  def del( key )
    redis.del( key )
  end

  # Sets

  def set_add( set_name, value )
    redis.sadd( set_name, value )
  end

  def set_size( set_name )
    redis.scard( set_name )
  end

  def set_remove( set_name, value )
    redis.srem( set_name, value )
  end

  def set_get_all( set_name )
    redis.smembers( set_name )
  end

  def set_member?( set_name, value )
    redis.sismember( set_name, value )
  end

  # Priority Queue

  def queue_add( queue_name, item, score )
    redis.zadd( queue_name, score, item )
  end

  # pop the lowest item from the queue IFF it scores <= max_score
  def queue_pop( queue_name, max_score = Time.now.to_i )
    # Option 1: zrange, check score, accept or discard
    # Option 2: zrangebyscore with limit, then zremrangebyrank

    redis.watch( queue_name )
    it = redis.zrangebyscore( queue_name, 0, max_score, :limit => [0,1] ).first
    if it then
      ok = redis.multi { |r| r.zremrangebyrank( queue_name, 0, 0 ) }
      it = nil if ! ok
    else
      redis.unwatch
    end
    it
  end

  def queue_pop_sync( queue_name, max_score = Time.now.to_i, options = {} )
    timeout  = options[:timeout] || 1
    deadline = Time.now.to_f + timeout

    loop do
      result = queue_pop( queue_name, max_score )
      return result if result

      raise Timeout::Error if Time.now.to_f > deadline
    end
  end

  def queue_del( queue_name )
    redis.del( queue_name )
  end

  # Maps

  def map_set( map_name, key, value )
    redis.hset( map_name, key, value )
  end

  def map_get( map_name, key )
    redis.hget( map_name, key )
  end

  def map_get_all_keys( map_name )
    redis.hkeys( map_name )
  end

  def map_size( map_name )
    redis.hlen( map_name )
  end

  def map_del( map_name, key )
    redis.hdel( map_name, key )
  end

  # ----------------------------------------------------------------------------
  # Redis
  # ----------------------------------------------------------------------------

  # @param redis_client can only be set once
  def redis=(redis_client)
    raise Hive::ConfigurationError if @redis
    @redis = redis_client
  end

  def redis
    @redis ||= ::Redis.connect( :url => "redis://127.0.0.1:6379/1" )
  end

end # Hive::Redis::Storage
