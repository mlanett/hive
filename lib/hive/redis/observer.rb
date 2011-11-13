# -*- encoding: utf-8 -*-

class Hive::Redis::Observer < Hive::Utilities::ObserverBase

  def worker_started
    @workers = "hive:workers"
    @worker  = "#{self.class.name}:#{Process.pid}"
    @status  = "hive:status:#{@worker}"
    storage.set_add( @workers, @worker )
    storage.set( @status, Time.now )
  end
  
  def worker_heartbeat( upcount = 0 )
    storage.set( @status, Time.now )
  end
  
  def worker_stopped
    storage.set_remove( @status )
    storage.srem( @workers, @worker )
  end
  
  def storage
    @storage ||= Hive.default_storage
  end
  
  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def worker_key( name )
    @hostname ||= `hostname`.chomp.strip
    "%s-%i@%s" % [ name, Process.pid, @hostname ]
  end
  
end # Hive::Redis::Observer
