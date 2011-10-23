# -*- encoding: utf-8 -*-

=begin

  A pool is a collection of workers, each of which is a separate process.
  All workers are of the same kind (class).

=end

class Hive::Pool

  attr :kind      # job class
  attr :policy
  attr :storage   # where to store worker details
  
  def initialize( kind, options, storage = default_storage )
    @kind      = class_by_scoped_name(kind)
    @policy    = Hive::Policy.new(options)
    @storage   = storage
  end
  
  def synchronize
    # launch workers
    policy.pool_min_workers.times do
      # puts "launch"
    end
  end
  
  # ----------------------------------------------------------------------------
  # Utilities
  # ----------------------------------------------------------------------------
  
  def class_by_scoped_name(c)
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
