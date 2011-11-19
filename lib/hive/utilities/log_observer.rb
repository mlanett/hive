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

  def worker_started( *args )
    log "Worker #{subject} has started"
  end
  
  def worker_heartbeat( *args )
    log "Worker #{subject} is still alive"
  end
  
  def job_error(x)
    log "Warning: Worker #{subject} experienced a job failure due to an error:#{x.inspect}"
  end
  
  def worker_stopped( *args )
    log "Worker #{subject} has stopped"
  end

end # Hive::Utilities::LogObserver
