# -*- encoding: utf-8 -*-

require 'ostruct'

=begin

  A registry knows how to lookup up and register workers.

=end

class Hive::Registry

  attr :name
  attr :storage

  def initialize( name, storage )
    @name    = name    or raise
    @storage = storage or raise

    # type checking
    name.encoding
  end


  def reconnect_after_fork
    @storage.reconnect_after_fork
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

  # ----------------------------------------------------------------------------
  # Query API
  # ----------------------------------------------------------------------------

  # @returns an array of key strings
  # NOTICE this will include keys for workers on all hosts
  def workers
    all = storage.set_get_all( workers_key )
    raise "Not a Set: #{workers_key} (#{all.class})" unless all.kind_of?(Array)
    all.map { |key_string| Hive::Key.parse(key_string) }
  end


  def checked_workers( policy )
    groups = { live: [], late: [], hung: [], dead: [] }
    check_workers(policy) do |key, status|
      groups[status] << key
    end
    OpenStruct.new(groups)
  end


  # This method can be slow so it takes a block for incremental processing.
  # @param block takes entry, status in [ :live, :late, :hung, :dead ]
  # @param options[:all] = true to get keys across all hosts
  def check_workers( policy, options = nil, &block )
    workers.each do |key|
      heartbeat = storage.get( status_key(key.to_s) ).to_i
      status    = heartbeat_status( policy, heartbeat )
      yield( key, status )
    end
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def heartbeat_status( policy, heartbeat )
    if heartbeat > 0 then
      age = now - heartbeat.to_i
      if age >= policy.worker_hung then
        :hung
      elsif age >= policy.worker_late
        :late
      else
        :live
      end
    else
      :dead
    end
  end


  # easier to test if we can stub Time.now
  def now
    Time.now.to_i
  end


  def policy
    @policy ||= Hive::Policy.resolve
  end


  def workers_key
    @workers_key ||= "hive:#{name}:workers"
  end


  def status_key( key )
    "hive:#{name}:worker:#{key}"
  end

end # Hive::Registry
