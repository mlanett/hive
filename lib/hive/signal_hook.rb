# -*- encoding: utf-8 -*-

=begin
  Allows you to add hooks without worrying about restoring the chain when you are done.
  Hooks can be nested.
  Only the most deeply nested handler will be called.

  Usage:
    hook = SignalHook.trap("TERM") { ... my term handler }
    hook.attempt do
      ... my long action
    end
    # at this point, term handler has been removed from chain
    
    or
    SignalHook.trap("QUIT") { foo.quit! }.attempt { foo.run }
=end

class Hive::SignalHook

  attr_writer :local, :chain

  def trigger
    if @local then
      @local.call
    elsif @chain
      @chain.call
    end
  end

  def attempt( &block )
    yield
  ensure
    @local = false
  end

  class << self
    def trap( signal, &block )
      hook       = SignalHook.new
      hook.local = block
      previous   = Signal.trap( signal ) { hook.trigger }
      hook.chain = previous if previous && previous.kind_of?(Proc)
      hook
    end # trap
  end

end # Hive::SignalHook
