# -*- encoding: utf-8 -*-
require 'ruby-debug'

class Hive::Monitor

  include Hive::Log

  attr :pools

  def initialize( configuration )
    @pools = configuration.jobs.map do |kind,options|
      pool = Hive::Pool.new( kind, Hive::Policy.resolve(options) )
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

  def restart
    pools.each do |pool|
      pool.restart
    end
  end

end
