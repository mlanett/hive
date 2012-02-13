# -*- encoding: utf-8 -*-

class Hive::Monitor

  include Hive::Log

  attr :pools
  attr :verbose

  def initialize( configuration )
    @verbose = configuration.verbose
    @pools = configuration.policies.map do |kind,policy|
      pool = Hive::Pool.new( kind, policy ).tap { |it| it.verbose = verbose }
    end
  end


  def monitor
    status = {}

    job = ->() do
      changed = false
      pools.each do |pool|

        log pool.name
        previous = status[pool.name]
        current  = pool.synchronize log: true

        if previous != current then
          status[pool.name] = current
          changed = true
        end

      end
      changed
    end

    job = Hive::Idler.new( job, min_sleep: 1, max_sleep: 10 )

    ok = true
    trap("TERM") { ok = false }
    while ok do
      job.call
    end
  end # monitor

  def stop_all
    pools.each do |pool|
      pool.stop_all
    end
  end

  def restart
    pools.each do |pool|
      pool.restart
    end
  end

end
