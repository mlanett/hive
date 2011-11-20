# -*- encoding: utf-8 -*-

=begin

  A registry knows how to lookup up and register workers.

=end

class Hive::Registry

  attr :name
  attr :storage

  def initialize( name, storage = Hive.default_storage )
    @name    = name
    @storage = storage

    # type checking
    name.encoding
  end

  def register( key )
    key = key.to_s
    storage.set_add( workers_key, key )
    storage.put( status_key(key), Time.now.to_i )
  end

  def update( key )
    key = key.to_s
    storage.set_add( workers_key, key ) if ! storage.set_member?( workers_key, key )
    storage.put( status_key(key), Time.now.to_i )
  end

  def unregister( key )
    key = key.to_s
    storage.del( status_key(key) )
    storage.set_remove( workers_key, key )
  end

  # @returns an array of key strings
  def workers
    all = storage.set_get_all( workers_key )
    all.map { |key_string| Hive::Key.parse(key_string) }
  end

  def live_workers( liveliness = 100 )
    raise "Incomplete"
  end

  # This method can be slow so it takes a block for incremental processing.
  def late_workers( liveliness = 100 )
    raise "Incomplete"
  end

  # This method can be slow so it takes a block for incremental processing.
  # @param liveliness should ~ equal Policy.worker_idle_max_sleep + expected job run time
  # @param block takes entry, status in [ :live, :hung, :dead ]
  def check_workers( liveliness = 100, &block )
    raise "Incomplete"
    workers.each do |key|
      yield( key, :wtf )
    end
  end

  # ----------------------------------------------------------------------------
    protected
  # ----------------------------------------------------------------------------

  def workers_key
    @workers_key ||= "hive:#{name}:workers"
  end

  def status_key( key )
    "hive:#{name}:worker:#{key}"
  end

end # Hive::Registry
