# -*- encoding: utf-8 -*-

=begin
  
  Wrapps a callable and issues feedback.
  - Started
  - Hearbeat
  - Error
  - Stopped
  
=end

class Hive::Utilities::NullObserver
  
  include Hive::Utilities::Observer

  attr :last_notification

  def worker_started()
    @last_notification = :worker_started
  end
  
  def heartbeat()
    @last_notification = :heartbeat
  end
  
  def job_error(x)
    @last_notification = :job_error
  end
  
  def worker_stopped()
    @last_notification = :worker_stopped
  end

end # Hive::Utilities::LogObserver
