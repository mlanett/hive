# -*- encoding: utf-8 -*-

class Hive::Policy

  DEFAULTS = {
    pool_min_workers:       1,
    pool_max_workers:       10,
    worker_idle_max_sleep:  64.0,
    worker_idle_min_sleep:  0.125,
    worker_idle_spin_down:  900,
    worker_none_spin_up:    86400,
    worker_max_jobs:        100,    # a worker should automatically exit after this many jobs
    worker_max_lifetime:    1000,   # a worker should automatically exit after this time
    worker_late:            10,     # a worker is overdue after this time with no heartbeat
    worker_hung:            100,    # a worker will be killed after this time
    storage:                :mock,
    observers:              []
  }

    def initialize( options = {} )
      options  = Hash[ options.map { |k,v| [ k.to_sym, v ] } ] # poor man's symbolize keys
      @options = DEFAULTS.merge( options )
    end

    def storage
      Hive::Utilities::StorageBase.resolve @options[:storage]
    end

    def method_missing( symbol, *arguments )
      @options[symbol.to_sym]
    end

    def merge( options = {} )
      @options.merge!( options )
      self
    end

    def dup
      self.class.new( @options.dup )
    end

    def before_fork
      (before_forks || []).each { |f| f.call }
    end

    def after_fork
      (after_forks || []).each { |f| f.call }
    end

  class << self
    # @returns a new policy
    # @options_or_policy can be a set of options or a source policy
    def resolve( options_or_policy = {} )
      # if it is a policy, just dup it
      options_or_policy.kind_of?(Hive::Policy) ? options_or_policy.dup : new(options_or_policy.dup)
    end

  end # class

end # Hive::Policy
