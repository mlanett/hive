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
