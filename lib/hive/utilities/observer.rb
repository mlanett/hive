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

  def self.resolve( candidate )
    case candidate
    when Class
      candidate.new
    when String, Symbol
      resolve(Hive.resolve_class(candidate.to_s))
    else
      case
      when candidate.respond_to?(:notify)
        candidate
      when candidate.respond_to?(:call)
        resolve(candidate.call)
      else
        return candidate # assume it supports the notifications natively
      end
    end
  end

end
