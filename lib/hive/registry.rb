# -*- encoding: utf-8 -*-

=begin

  A registry knows how to lookup up and register workers.

=end

class Hive::Registry

  class Entry < Struct.new :pid, :key
  end

  attr :storage

  def initialize( pool, storage = Hive.default_storage )
    @pool    = pool
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

  # ----------------------------------------------------------------------------
  # Utilities
  # key format
  # ----------------------------------------------------------------------------

  module Utilities

    # e.g. processor-1234@foo.example.com
    def make_key( name, pid, host )
      "%s-%i@%s" % [ name, pid, host ]
    end

    def parse_key(key)
      at       = key.rindex("@")
      name_pid = key[ 0 .. at-1 ]
      host     = key[ at+1 .. -1 ]
      dash     = name_pid.rindex("-")
      name     = name_pid[ 0 .. dash-1 ]
      pid      = name_pid[ dash+1 .. -1 ]
      [ name, pid, host ]
    end

  end # Utilities

  extend Utilities

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def workers_key
    @workers_key ||= "hive:#{@pool}:workers"
  end

  def status_key( key )
    "hive:#{@pool}:worker:#{key}"
  end

end # Hive::Registry
