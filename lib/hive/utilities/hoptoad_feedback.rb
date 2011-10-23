# -*- encoding: utf-8 -*-

=begin
  
  Wrapps a callable and issues feedback.
  - Error
  
=end

require "hoptoad_notifier"

class Hive::Utilities::HoptoadFeedback
  
  attr :it # job
  attr :me # worker
  
  def initialize( observed, callable = nil, &callable_block )
    @it = callable || callable_block
    @me = observed
  end
  
  def with_feedback( &block )
    yield
  end
  
  def job_error(x)
    HoptoadNotifier.notify(x)
  end
  
  def call( *args, &block )
    begin
      it.call( *args, &block )
    rescue => x
      job_error(x)
      raise x
    end
  end
  
end # Hive::Feedback
