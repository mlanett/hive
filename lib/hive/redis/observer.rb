# -*- encoding: utf-8 -*-

class Hive::Redis::Observer < Hive::Utilities::ObserverBase

  def notify_started
    @ro_workers = "hive:workers"
    @ro_worker  = "#{self.class.name}:#{Process.pid}"
    @ro_status  = "hive:status:#{@ro_worker}"
    redis.sadd( @ro_workers, @ro_worker )
    notify_alive
  end
  
  def notify_alive( upcount = 0 )
    redis.set( @ro_status, Time.now )
  end
  
  def notify_stopped
    redis.del( @ro_status )
    redis.srem( @ro_workers, @ro_worker )
  end
  
  def redis
    Hive::Redis::Observer.redis
  end
  
  class << self
    attr :redis, true
  end # class
  
  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def worker_key( name )
    @hostname ||= `hostname`.chomp.strip
    "%s-%i@%s" % [ name, Process.pid, @hostname ]
  end
  
end # Hive::Redis::Observer
