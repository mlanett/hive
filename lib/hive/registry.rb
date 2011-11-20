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

  def live_workers( liveliness = 100, &block )
    workers.each(&block)
    raise "Incomplete"
  end

  # This method can be slow so it takes a block for incremental processing.
  def late_workers( liveliness = 100 )
    raise "Incomplete"
  end

  # This method can be slow so it takes a block for incremental processing.
  # @param liveliness should ~ equal Policy.worker_idle_max_sleep + expected job run time
  # @param block takes key, status in [ :live, :hung, :dead ]
  def check_workers( liveliness = 100, &block )
    workers.each do |key|
      name, pid, host = parse_key(key)
      raise "Incomplete"
    end
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

  # @returns something like foo.example.com
  def hostname
    @hostname ||= `hostname`.chomp.strip
  end

  def workers_key
    @workers_key ||= "hive:#{@pool}:workers"
  end

  def status_key( key )
    "hive:#{@pool}:worker:#{key}"
  end

end # Hive::Registry
