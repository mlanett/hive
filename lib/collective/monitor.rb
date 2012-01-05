# -*- encoding: utf-8 -*-
require 'ruby-debug'

class Collective::Monitor

  include Collective::Log

  attr :pools

  def initialize( configuration )
    @pools = configuration.policies.map do |kind,policy|
      pool = Collective::Pool.new( kind, policy )
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

    job = Collective::Idler.new( job, min_sleep: 1, max_sleep: 10 )

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