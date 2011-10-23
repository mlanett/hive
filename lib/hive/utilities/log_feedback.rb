# -*- encoding: utf-8 -*-

=begin
  
  Wrapps a callable and issues feedback.
  - Started
  - Hearbeat
  - Error
  - Stopped
  
=end

class Hive::LogFeedback
  
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
  
  def heartbeat()
    log "Worker #{me} is still alive"
  end
  
  def job_error(x)
    log "A job #{it} failed with an error:#{x.inspect}, in worker #{me}"
  end
  
  def worker_stopped()
    log "Stopped"
  end

end # Hive::Feedback
