# -*- encoding: utf-8 -*-

=begin

  A pool is a collection of workers, each of which is a separate process.
  All workers are of the same kind (class).

=end

class Hive::Pool

  include Hive::Log

  attr :kind      # job class
  attr :name
  attr :policy
  attr :registry
  attr :storage   # where to store worker details

  def initialize( kind, policy_prototype = nil, storage = Hive.default_storage )
    if kind.kind_of?(Array) then
      kind, policy_prototype = kind.first, kind.last
    end
    @kind     = kind
    @policy   = Hive::Policy.resolve(policy_prototype)
    @name     = @policy.name || @kind.name or raise Hive::ConfigurationError, "Pool or Job must have a name"
    @registry = Hive::Registry.new( name, storage )
    @storage  = storage

    # type checks
    policy.pool_min_workers
    registry.workers
  end


  def synchronize()
    checklist = registry.checked_workers( policy )

    live = check_live_workers( checklist )
    check_late_workers( checklist )
    check_hung_workers( checklist )
    check_remote_workers( checklist )

    # we should have between pool_min_workers and pool_max_workers workers
    expected = policy.pool_min_workers

    # launch workers
    (expected - live).times do
      spawn
    end

    checklist = registry.checked_workers( policy )
  end


  def rpc
    @rpc ||= begin
      key = Hive::Key.new( "#{name}-pool", Process.pid )
      me  = Hive::Messager.new storage, my_address: key
    end
  end


  # this really should be protected but it's convenient to be able to force a spawn
  def spawn()
    Hive::Worker.spawn kind, registry: registry, policy: policy, name: name
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def check_live_workers( checked )
    if live = checked[:live] and live.size > 0 then
      log "Live worker count #{live.size}; members: #{live.inspect}"
      live.size
    else
      0
    end
  end


  def check_late_workers( checked )
    if late = checked[:late] and late.size > 0 then
      log "Late worker count #{late.size}; members: #{late.inspect}"
      late.size
    else
      0
    end
  end


  def check_hung_workers( checked )
    if hung = checked[:hung] and hung.size > 0 then
      log "Hung worker count #{hung.size}"
      hung.each do |key|
        log "Killing #{key}"
        Hive::Utilities::Process.wait_and_terminate( key.pid )
        registry.unregister(key)
      end
    end
    0
  end


  def check_remote_workers( checked )
    if remote = checked[:remote] and remote.size > 0 then
      log "Remote worker count #{remote.size}; members: #{remote.inspect}"
      remote.size
    else
      0
    end
  end

end # Hive::Pool
