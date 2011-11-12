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
      Hive::Worker.spawn( kind, policy )
    end
  end
  
  # ----------------------------------------------------------------------------
  # Utilities
  # ----------------------------------------------------------------------------
  
  def resolve_kind(c)
    case c
    when Class
      c
    when String, Symbol
      resolve_class(c.to_s)
    else
      # proc or lambda
      raise unless c.respond_to?(:call)
      c
    end
  end

  def resolve_class(c)
    c.split(/::/).inject(Object) { |a,i| a.const_get(i) }
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
