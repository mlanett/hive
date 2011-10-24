# -*- encoding: utf-8 -*-

class Hive::Policy

  def initialize( options = {} )
    @options = options
  end

  class << self
    def declare_i( name, default_value )
      name_s = name.to_s
      define_method( name.to_sym ) do
        i( name_s, default_value )
      end
    end
    def declare_f( name, default_value )
      name_s = name.to_s
      define_method( name.to_sym ) do
        f( name_s, default_value )
      end
    end
  end

  declare_i :pool_min_workers,      1
  declare_i :pool_max_workers,      10
  declare_f :worker_idle_max_sleep, 64
  declare_f :worker_idle_min_sleep, 0.125
  declare_i :worker_idle_spin_down, 900
  declare_i :worker_none_spin_up,   86400
  declare_i :worker_max_jobs,       100     # a worker should automatically exit after this many jobs
  declare_i :worker_max_lifetime,   1000    # a worker should automatically exit after this time
  declare_i :worker_late_warn,      10      # a worker is overdue after this time with no heartbeat
  declare_i :worker_late_kill,      100     # a worker must be killed after this time

  private

  def i( key, default_value = 0 )
    @options.has_key?(key) ? @options[key].to_i : default_value.to_i
  end

  def f( key, default_value = 0.0 )
    @options.has_key?(key) ? @options[key].to_f : default_value.to_f
  end

end # Hive::Policy
