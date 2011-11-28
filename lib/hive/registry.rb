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

  # ----------------------------------------------------------------------------
  # Query API
  # ----------------------------------------------------------------------------

  # @returns an array of key strings
  # NOTICE this will include keys for workers on all hosts
  def workers
    all = storage.set_get_all( workers_key )
    all.map { |key_string| Hive::Key.parse(key_string) }
  end

  def checked_workers( policy )
    groups = {}
    check_workers(policy) do |key, status|
      groups[status] ||= []
      groups[status] << key
    end
    groups
  end

  # This method can be slow so it takes a block for incremental processing.
  # @param block takes entry, status in [ :live, :late_warn, :late_kill, :dead ]
  # @param options[:all] = true to get keys across all hosts
  def check_workers( policy, options = nil, &block )
    all = options && options[:all]
    workers.each do |key|
      if all || key.host == Hive::Key.local_host then
        heartbeat = storage.get( status_key(key.to_s) ).to_i
        status    = heartbeat_status( policy, heartbeat )
        yield( key, status )
      end
    end
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def heartbeat_status( policy, heartbeat )
    if heartbeat > 0 then
      age = now - heartbeat.to_i
      if age >= policy.worker_late_kill then
        :late_kill
      elsif age >= policy.worker_late_warn
        :late_warn
      else
        :live
      end
    else
      :dead
    end
  end

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
