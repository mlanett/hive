# -*- encoding: utf-8 -*-

=begin
  
  Wrapps a callable and issues feedback.
  - Started
  - Hearbeat
  - Error
  - Stopped
  
=end

class Hive::Utilities::LogObserver < Hive::Utilities::ObserverBase
  
  include Hive::Log

  attr :it # job
  attr :me # worker
  
  def initialize( observed, callable = nil, &callable_block )
    @it = callable || callable_block
    @me = observed
  end
  
  def worker_started()
    log "Worker #{me} has started"
  end
  
  def worker_heartbeat()
    log "Worker #{me} is still alive"
  end
  
  def job_error(x)
    log "Warning: Worker #{me} experienced a job failure due to an error:#{x.inspect}; job was #{it}"
  end
  
  def worker_stopped()
    log "Worker #{me} has stopped"
  end

end # Hive::Utilities::LogObserver
