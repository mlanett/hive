class Hive::Policy
  
  def initialize( options = {} )
    @options = options
  end
  
  class << self
    def declare_f( name, default_value )
      name_s = name.to_s
      define_method( name.to_sym ) do
        f( name_s, default_value )
      end
    end
  end
  
  declare_f :worker_idle_min_sleep, 0.125
  declare_f :worker_idle_max_sleep, 64
  declare_f :worker_idle_spin_down, 1024
  declare_f :worker_none_spin_up,   65536
  
  private
  
  def f( key, default_value = 0 )
    @options.has_key?(key) ? @options[key].to_f : default_value
  end
  
end # Hive::Policy
