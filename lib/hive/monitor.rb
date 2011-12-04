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
    loop do
      pools.each do |pool|
        r = pool.registry
        log pool.name
        log r.workers.inspect
        log r.checked_workers(pool.policy).inspect
        if remote = r.checked_workers(pool.policy)[:remote] and remote.size > 0 then
          log "Remote worker count #{remote.size}; members: #{remote.inspect}"
        end
      end
      sleep(2)
    end
  end

end
