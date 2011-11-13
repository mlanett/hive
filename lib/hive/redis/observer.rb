# -*- encoding: utf-8 -*-

class Hive::Redis::Observer < Hive::Utilities::ObserverBase

  def worker_started
    @workers = "hive:workers"
    @worker  = "#{self.class.name}:#{Process.pid}"
    @status  = "hive:status:#{@worker}"
    redis.sadd( @workers, @worker )
    redis.set( @status, Time.now )
  end
  
  def worker_heartbeat( upcount = 0 )
    redis.set( @status, Time.now )
  end
  
  def worker_stopped
    redis.del( @status )
    redis.srem( @workers, @worker )
  end
  
  def redis
    @redis ||= Hive::Redis::Observer.default_redis
  end
  
  class << self
    attr :default_redis, true
  end # class
  
  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def worker_key( name )
    @hostname ||= `hostname`.chomp.strip
    "%s-%i@%s" % [ name, Process.pid, @hostname ]
  end
  
end # Hive::Redis::Observer
