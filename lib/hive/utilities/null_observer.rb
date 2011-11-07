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

  attr :notifications

  def initialize
    @notifications = []
  end

  def worker_started()
    @notifications << :worker_started
  end
  
  def heartbeat()
    @notifications << :heartbeat
  end
  
  def job_error(x)
    @notifications << :job_error
  end
  
  def worker_stopped()
    @notifications << :worker_stopped
  end

end # Hive::Utilities::LogObserver
