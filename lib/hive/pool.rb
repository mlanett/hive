# -*- encoding: utf-8 -*-

=begin

  A pool is a collection of workers, each of which is a separate process.
  All workers are of the same kind (class).

=end

class Hive::Pool

  attr :kind      # job class
  attr :policy
  attr :storage   # where to store worker details
  
  def initialize( kind, policy, storage = default_storage )
    @kind      = find_kind(kind)
    @policy    = policy
    @storage   = storage
  end
  
  def synchronize
    # launch workers
    job = kind.respond_to?(:call) ? kind : kind.respond_to?(:new) ? kind.new : kind
    policy.pool_min_workers.times do
      w = Hive::Worker.new( policy, job )
      # puts "launch"
    end
  end
  
  # ----------------------------------------------------------------------------
  # Utilities
  # ----------------------------------------------------------------------------
  
  def find_kind(c)
    case c
    when Class
      c
    when String, Symbol
      find_class(c)
    else
      # proc or lambda
      raise unless c.respond_to?(:call)
      c
    end
  end

  def find_class(c)
    c.to_s.split(/::/).inject(Object) { |a,i| a.const_get(i) }
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
