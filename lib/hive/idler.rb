# -*- encoding: utf-8 -*-

=begin

Idler wraps some other callable (a proc or object which responds to #call)
The callable should return a falsy value when it did nothing,
or a truthy value when it did something.
The idler will sleep when there is nothing to do.

=end

class Hive::Idler
  
  MIN_SLEEP = -3
  MAX_SLEEP = 0
  
  attr :sleep
  
  def initialize( callable = nil, &callable_block )
    @callable = callable || callable_block
    @sleep    = nil
  end
  
  def call( *args, &block )
    
    result = nil
    begin
      result = @callable.call(*args,&block)
    rescue Exception                          # when errors occur,
      @sleep  = MIN_SLEEP                     # reduce sleeping almost all the way
      raise                                   # do not consume any exceptions
    end
    
    if result then
      @sleep = nil                            # stop sleeping
    else
                                              # don't actually sleep on first pass
      Kernel.sleep(2**@sleep) if @sleep       # Interrupt will propogate through sleep().
                                              # sleep longer next time
      @sleep = @sleep ? [ @sleep+1, MAX_SLEEP ].min : MIN_SLEEP
    end
    
    return result
  end
  
end # Hive::Idler
