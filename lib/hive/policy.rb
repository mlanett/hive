# -*- encoding: utf-8 -*-

require "ostruct"

class Hive::Policy
  class << self

    DEFAULTS = {
      pool_min_workers:       1,
      pool_max_workers:       10,
      worker_idle_max_sleep:  64.0,
      worker_idle_min_sleep:  0.125,
      worker_idle_spin_down:  900,
      worker_none_spin_up:    86400,
      worker_max_jobs:        100,    # a worker should automatically exit after this many jobs
      worker_max_lifetime:    1000,   # a worker should automatically exit after this time
      worker_late_warn:       10,     # a worker is overdue after this time with no heartbeat
      worker_late_kill:       100,    # a worker must be killed after this time
      observers:              []
    }

    def policy( options = nil )
      case options
      when nil
        OpenStruct.new( DEFAULTS )
      when Hash
        options = Hash[ options.map { |k,v| [ k.to_sym, v ] } ] # poor man's symbolize keys
        OpenStruct.new( DEFAULTS.merge( options ) )
      when OpenStruct
        # We COULD write the defaults into here or we could assume we got it this way already.
        options.dup
      else
        raise "Unable to make policy"
      end
    end

  end # class
end # Hive::Policy
