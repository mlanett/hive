# -*- encoding: utf-8 -*-

=begin
  
  Wrapps a callable and issues feedback.
  - Error
  
=end

require "hoptoad_notifier"

class Hive::Utilities::HoptoadObserver
  
  include Hive::Utilities::Observer

  attr :it # job
  attr :me # worker
  
  def initialize( observed, callable = nil, &callable_block )
    @it = callable || callable_block
    @me = observed
  end

  def job_error(x)
    HoptoadNotifier.notify(x)
  end

end # Hive::Utilities::HoptoadObserver
