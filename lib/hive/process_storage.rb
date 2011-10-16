# -*- encoding: utf-8 -*-

class Hive::ProcessStorage
  
  def initialize
    @storage = {}
  end
  
  def put( key, value )
    @storage[key] = value
  end
  
  def get( key )
    @storage[key]
  end
  
  def del( key )
    @storage.delete(key)
  end
  
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
  
  def set_members( key )
    @storage[key] || []
  end
  
  def map_set( key, name, value )
    @storage[key] ||= {}
    @storage[key][name] = value
  end
  
  def map_get( key, name )
    (@storage[key] || {}) [name]
  end
  
  def map_get_all( key )
    (@storage[key] || {})
  end
  
  def map_size( key )
    (@storage[key] || {} ).size
  end
  
  def map_del( key )
    @storage.delete(key)
  end
  
end # Hive::ProcessStorage
