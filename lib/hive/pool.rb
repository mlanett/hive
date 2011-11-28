# -*- encoding: utf-8 -*-

=begin

  A pool is a collection of workers, each of which is a separate process.
  All workers are of the same kind (class).

=end

class Hive::Pool

  attr :kind      # job class
  attr :name
  attr :policy
  attr :registry
  attr :storage   # where to store worker details

  def initialize( kind, policy_prototype = nil, storage = Hive.default_storage )
    @kind     = kind
    @policy   = Hive::Policy.resolve(policy_prototype)
    @name     = @policy.name || @kind.name or raise Hive::ConfigurationError, "Pool or Job must have a name"
    @registry = Hive::Registry.new( name, storage )
    @storage  = storage

    # type checks
    policy.pool_min_workers
    registry.workers
  end
  
  def synchronize

    check_dead_workers

    # we should have between pool_min_workers and pool_max_workers workers
    running  = check_live_workers
    expected = policy.pool_min_workers

    # launch workers
    (expected - running).times do
      spawn
    end
  end

  def check_dead_workers
  end

  def check_live_workers
    0
  end

  def spawn()
    Hive::Worker.spawn kind, registry: registry, policy: policy, name: name
  end

end # Hive::Pool
