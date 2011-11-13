# -*- encoding: utf-8 -*-

=begin

  A pool is a collection of workers, each of which is a separate process.
  All workers are of the same kind (class).

=end

class Hive::Pool

  attr :kind      # job class
  attr :policy
  attr :storage   # where to store worker details
  
  def initialize( kind, policy = Hive::Policy.new, storage = default_storage )
    @kind      = resolve_kind(kind)
    @policy    = policy
    @storage   = storage
  end
  
  def synchronize
    # launch workers
    policy.pool_min_workers.times do
      spawn
    end
  end

  def spawn()
    Hive::Worker.spawn( kind, policy )
  end

  # ----------------------------------------------------------------------------
  # Utilities
  # ----------------------------------------------------------------------------
  
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

  # ----------------------------------------------------------------------------
  # Configuration
  # ----------------------------------------------------------------------------
  
  def default_storage
    Hive::Pool.default_storage ||= Hive::ProcessStorage.new
  end
  
  class << self
    attr :default_storage, true
  end # class
  
end # Hive::Pool
