# -*- encoding: utf-8 -*-

=begin

  A pool is a collection of workers, each of which is a separate process.
  All workers are of the same kind (class).

=end

class Hive::Pool

  attr :kind      # job class
  attr :name
  attr :policy
  attr :storage   # where to store worker details
  
  def initialize( kind, policy = {}, storage = Hive.default_storage )
    @kind     = resolve_kind(kind)
    @policy   = Hive::Policy.resolve(policy)
    @name     = @policy.name || @kind.name or raise "Pool or Job must have a name"
    @registry = Hive::Registry.new(storage)
    @storage  = storage
  end
  
  def synchronize
    # launch workers
    policy.pool_min_workers.times do
      spawn
    end
  end

  def spawn()
    Hive::Worker.spawn( kind, registry, policy )
  end

  # ----------------------------------------------------------------------------
  # Utilities
  # ----------------------------------------------------------------------------

  # A kind is a job factory.
  # It could be a proc, which is cloneable. A proc has no name.
  # It could be a class, which can be instantiated.
  # It could be an instance, which is cloneable. An instance could have a constant #name.
  def resolve_kind(kind)
    case kind
    when Class
      kind
    when String, Symbol
      Hive.resolve_class(kind.to_s)
    else
      # proc or lambda
      raise unless kind.respond_to?(:call)
      kind
    end
  end

  def registry
    @registry ||= begin
      Hive::Registry.new( name, storage )
    end
  end

end # Hive::Pool
