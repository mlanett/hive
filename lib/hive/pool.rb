# -*- encoding: utf-8 -*-

=begin

  A pool is a collection of workers, each of which is a separate process.
  All workers are of the same kind (class).

=end

class Hive::Pool

  include Hive::Log
  include Hive::Utilities::Hash

  attr :kind      # job class
  attr :name
  attr :policy
  attr :registry
  attr :storage   # where to store worker details

  def initialize( kind, policy_prototype = {} )
    if kind.kind_of?(Array) then
      kind, policy_prototype = kind.first, kind.last
    end
    @kind     = kind
    @policy   = Hive::Policy.resolve(policy_prototype) or raise
    @name     = @policy.name || kind.name or raise Hive::ConfigurationError, "Pool or Job must have a name"
    @storage  = policy.storage
    @registry = Hive::Registry.new( name, storage )

    # type checks
    policy.pool_min_workers
    registry.workers
  end


  # @param options[:log] can be true
  # @returns the checked worker lists
  def synchronize( options = {} )
    assert_valid_keys( options, :log )
    do_log = options[:log]

    checklist  = registry.checked_workers( policy )
    live_count = checklist.live.size

    if do_log then
      check_live_workers( checklist )
      check_late_workers( checklist )
      check_hung_workers( checklist )
      check_dead_workers( checklist )
    end

    if (need = policy.pool_min_workers - live_count) > 0 then
      # launch workers
      need.times do
        spawn wait: true
      end

    elsif (excess = live_count - policy.pool_max_workers) > 0 then
      # spin down some workers
      # try to find LOCAL workers to spin down first
      locals = checklist.live.select { |k| k.host == Hive::Key.local_host }
      if locals.size > 0 then
        reap locals.first, wait: true
      else
        reap checklist.live.first, wait: true
      end
    end

    checklist = registry.checked_workers( policy )
  end


  def mq
    @mq ||= begin
      key = Hive::Key.new( "#{name}-pool", Process.pid )
      me  = Hive::Messager.new storage, my_address: key
    end
  end


  # tell all workers to quit
  def stop_all
    checklist = registry.checked_workers( policy )
    checklist.live.each { |key| reap(key) }
    checklist.late.each { |key| reap(key) }
    checklist.hung.each { |key| reap(key) }
    checklist.dead.each { |key| reap(key) }
  end


  # this really should be protected but it's convenient to be able to force a spawn
  # param options[:wait] can true to wait until after the process is spawned
  def spawn( options = {} )
    assert_valid_keys( options, :wait )
    wait = options[:wait]

    if ! wait then
      Hive::Worker.spawn kind, registry: registry, policy: policy, name: name
      return
    end

    before = registry.checked_workers( policy ).live

    Hive::Worker.spawn kind, registry: registry, policy: policy, name: name

    Hive::Idler.wait_until( 10 ) do
      after = registry.checked_workers( policy ).live
      diff  = ( after - before ).select { |k| k.host == Hive::Key.local_host }
      diff.size > 0
    end
  end


  # shut down a worker
  def reap( key, options = {} )
    assert_valid_keys( options, :wait )
    wait = options[:wait]

    if key.host == Hive::Key.local_host then
      ::Process.kill( "TERM", key.pid )
      Hive::Utilities::Process.wait_and_terminate key.pid, timeout: 10
    else
      mq.send "Quit", to: key
    end

    if wait then
      Hive::Idler.wait_until( 10 ) do
        live = registry.checked_workers( policy ).live
        ! live.member? key
      end
    end
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def check_live_workers( checked )
    if live = checked.live and live.size > 0 then
      log "Live worker count #{live.size}; members: #{live.inspect}"
      live.size
    else
      0
    end
  end


  def check_late_workers( checked )
    if late = checked.late and late.size > 0 then
      log "Late worker count #{late.size}; members: #{late.inspect}"
      late.size
    else
      0
    end
  end


  def check_hung_workers( checked )
    if hung = checked.hung and hung.size > 0 then
      log "Hung worker count #{hung.size}"
      hung.each do |key|
        log "Killing #{key}"
        Hive::Utilities::Process.wait_and_terminate( key.pid )
        registry.unregister(key)
      end
    end
    0
  end


  def check_dead_workers( checked )
    if dead = checked.dead and dead.size > 0 then
      log "Dead worker count #{dead.size}; members: #{dead.inspect}"
      dead.size
    else
      0
    end
  end

end # Hive::Pool
