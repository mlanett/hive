# -*- encoding: utf-8 -*-

=begin

Idler wraps some other callable (a proc or object which responds to #call)
The callable should return a falsy value when it did nothing,
or a truthy value when it did something.
The idler will sleep when there is nothing to do.

=end

class Hive::Idler
  
  MIN_SLEEP = 0.125
  MAX_SLEEP = 1.0
  
  attr :sleep
  
  def initialize( callable = nil, options = {}, &callable_block )
    @callable = callable || callable_block
    raise unless @callable.respond_to?(:call)

    @max_sleep = options[:max_sleep] || MAX_SLEEP
    raise if @max_sleep <= 0

    @min_sleep = options[:min_sleep] || MIN_SLEEP
    raise if @min_sleep <= 0
    raise if @max_sleep < @min_sleep

    @sleep     = nil
  end
  
  def call( *args, &block )
    
    result = call_with_wakefulness( @callable, *args, &block )

    if result then
      wake
    else
      sleep_more
    end

    return result
  end

  def call_with_wakefulness( callable, *args, &block )
    begin
      callable.call(*args,&block)
    rescue Exception                          # when errors occur,
      @sleep = @min_sleep                     # reduce sleeping almost all the way (but not to 0)
      raise                                   # do not consume any exceptions
    end
  end

  def sleep_more
    if @sleep then
      @sleep = [ @sleep * 2, @max_sleep ].min
    else
      @sleep = @min_sleep
    end
    Kernel.sleep(@sleep) if @sleep          # Interrupt will propogate through sleep().
  end

  def wake
    @sleep = nil
  end

  module Utilities
    # execute test repeatedly, until timeout, or until test returns true
    def wait_until( timeout = 1, &test )
      tester = Hive::Idler.new(test)
      finish = Time.now.to_f + timeout
      loop do
        break if tester.call
        break if finish < Time.now.to_f
      end
    end
  end
  extend Utilities

end # Hive::Idler
