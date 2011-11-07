# -*- encoding: utf-8 -*-

module Hive::Utilities::Observer

  # can implement notify( observeable, *details )
  # or can use this implementation

  def notify( observeable, *details )
    if self.respond_to?(details.first) then
      details = details.dup
      self.send( details.shift, *details )
    end
  end

  def self.realize( candidate )
    case candidate
    when candidate.respond_to?(:notify)
      candidate
    when candidate.respond_to?(:call)
      realize(candidate.call)
    when Class
      candidate.new
    when String, Symbol
      realize(find_class(candidate))
    else
      raise "Unknown kind of observer #{candidate.inspect}"
      return candidate # assume it supports the notifications natively
    end
  end

  def self.find_class(c)
    c.to_s.split(/::/).inject(Object) { |a,i| a.const_get(i) }
  end

end
