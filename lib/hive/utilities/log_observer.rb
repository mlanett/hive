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
    log "#{subject} has started"
  end
  
  def worker_heartbeat( *args )
    log "#{subject} is still alive"
  end
  
  def job_error(x)
    log "Warning: #{subject} experienced a job failure due to an error:#{x.inspect}"
  end
  
  def worker_stopped( *args )
    log "#{subject} has stopped"
  end

end # Hive::Utilities::LogObserver
