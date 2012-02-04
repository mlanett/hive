# -*- encoding: utf-8 -*-

class Hive::Mocks::Storage
  
  def initialize
    @storage = {}
  end

  def reconnect_after_fork
    # nop
  end

  def to_s
    "#{self.class.name}()"
  end

  # Simple values

  def put( key, value )
    @storage[key] = value
  end
  
  def get( key )
    @storage[key]
  end
  
  def del( key )
    @storage.delete( key )
  end

  # Sets

  def set_add( key, value )
    @storage[key] ||= []
    @storage[key] << value unless @storage[key].member?(value)
  end
  
  def set_size( key )
    (@storage[key] || [] ).size
  end
  
  def set_remove( key, value )
    (@storage[key] || [] ).delete( value )
  end

  def set_member?( key, value )
    (@storage[key] || []).member?( value )
  end

  def set_get_all( key )
    @storage[key] || []
  end

  # Maps

  def map_set( key, name, value )
    @storage[key] ||= {}
    @storage[key][name] = value
  end
  
  def map_get( key, name )
    (@storage[key] || {}) [name]
  end
  
  def map_get_all_keys( key )
    (@storage[key] || {}).keys
  end
  
  def map_size( key )
    (@storage[key] || {} ).size
  end
  
  def map_del( key )
    @storage.delete( key )
  end

  # Priority Queue

  def queue_add( queue_name, item, score )
    queue = @storage[queue_name] ||= []
    queue << [ item, score ]
    queue.sort_by! { |it| it.last }
  end

  # pop the lowest item from the queue IFF it scores <= max_score
  def queue_pop( queue_name, max_score = Time.now.to_i )
    queue = @storage[queue_name] || []
    return nil if queue.size == 0
    if queue.first.last <= max_score then
      queue.shift.first
    else
      nil
    end
  end

  def queue_pop_sync( queue_name, max_score = Time.now.to_i, options = {} )
    timeout  = options[:timeout] || 1
    deadline = Time.now.to_f + timeout

    loop do
      result = queue_pop( queue_name, max_score )
      return result if result

      raise Timeout::Error if Time.now.to_f > deadline
    end
  end

  def queue_del( queue_name )
    @storage.delete( queue_name )
  end
  
end # Hive::Mocks::Storage
