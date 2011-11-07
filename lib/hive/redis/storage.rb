# -*- encoding: utf-8 -*-

class Hive::Redis::Storage

  def initialize( redis  )
    @redis = redis
  end

  # Simple values

  def put( key, value )
    redis.set( key, value )
  end
  
  def get( key )
    redis.get(key)
  end

  def del( key )
    redis.del(key)
  end

  # Sets

  def set_add( key, value )
    redis.sadd( key, value )
  end

  def set_size( key )
    redis.scard( key )
  end

  def set_remove( key, value )
    redis.srem( key, value )
  end

  def set_members( key )
    redis.smembers(key)
  end

  # Maps

  def map_set( key, name, value )
    redis.hset( key, name, value )
  end

  def map_get( key, name )
    redis.hget( key, name )
  end

  def map_get_all( key )
    redis.hgetall
  end

  def map_size( key )
    redis.hlen(key)
  end

  def map_del( key )
    redis.hdel( key )
  end

  # Redis

  # @param redis_client can only be set once
  def redis=(redis_client)
    raise if @redis
    @redis = redis_client
  end

  def redis
    @redis ||= ::Redis.connect( :url => "redis://127.0.0.1:6379/1" )
  end

end # Hive::Redis::Storage
