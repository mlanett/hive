# -*- encoding: utf-8 -*-

=begin

  A registry knows how to lookup up and register workers.

=end

class Hive::Registry

  class Entry < Struct.new :pid, :key
  end

  attr :storage

  def initialize( storage = Hive.default_storage )
    @storage = storage
  end

  def register( key )
    storage.set_add( workers_key, key )
    storage.put( status_key(key), Time.now )
  end

  def update( key )
    storage.set_add( workers_key, key ) if ! storage.set_member?( workers_key, key )
    storage.put( status_key(key), Time.now )
  end

  def unregister( key )
    storage.del( status_key(key) )
    storage.set_remove( workers_key, key )
  end

  def workers
    storage.set_get_all( workers_key )
  end

  def live_workers( &block )
    workers.each(&block)
  end

  def with_registration( key, &block )
    register(key)
    begin
      yield
    ensure
      unregister(key)
    end
  end

  protected

  def workers_key
    "hive:workers"
  end

  def status_key( key )
    "hive:status:#{key}"
  end

end # Hive::Registry
