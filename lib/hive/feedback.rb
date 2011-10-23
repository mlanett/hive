# -*- encoding: utf-8 -*-

=begin
  
  Wrapps a callable and issues feedback.
  - Started
  - Hearbeat
  - Error
  - Stopped
  
=end

class Hive::Feedback
  
  attr :it # job
  attr :me # worker
  
  def initialize( observed, callable = nil, &callable_block )
    @it = callable || callable_block
    @me = observed
  end
  
  def with_feedback( &block )
    worker_started
    begin
      yield
    ensure
      worker_stopped
    end
  end
  
  def call( *args, &block )
    begin
      it.call( *args, &block )
    rescue => x
      job_error(x)
      raise x
    ensure
      heartbeat
    end
  end
  
  #
  # Feedback callbacks
  #
  
  def worker_started
  end
  
  def heartbeat
  end
  
  def job_error(x)
  end
  
  def worker_stopped
  end

end # Hive::Feedback
