# -*- encoding: utf-8 -*-

module Timing

  def time(&block)
    _time(&block)
    elapsed
  end

  protected

  def start
    @start = Time.now.to_f
  end

  def finish
    @finish = Time.now.to_f
  end

  def elapsed
    @finish - @start
  end

  def _time(&block)
    # elapsed time should be known whether or not it raises an error
    start
    yield
  ensure
    finish
  end

end # Timing
