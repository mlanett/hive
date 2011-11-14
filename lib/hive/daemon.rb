# -*- encoding: utf-8 -*-

require "daemon_spawn"
require "hive"

class Hive::Daemon < DaemonSpawn::Base
  
  include Hive::Log
  
  def start( arguments )
    trap("TERM") { stop } # Replace daemon_spawn's exit() with an async stop
    
    my = arguments[0] or raise "Missing configuration"

    raise # XXX this is all broken
    
    pools = conf.map do |name,options|
      if ! pclass = options.delete("class") then
        log "Can not use pool #{name}"
        next
      end
      pool = Hive::Pool.new( pclass, Hive::Policy.policy(options) )
    end
    
    i = Hive::Idler.new do
      pools.each { |pool| pool.synchronize }
      false
    end
    
    @ok = true
    while @ok do
      i.call
    end
    
    # Shut down all the pools
    
    log "Done"
  end
  
  def stop
    log "Stopping"
    @ok = false
  end
  
end # Hive::Daemon
