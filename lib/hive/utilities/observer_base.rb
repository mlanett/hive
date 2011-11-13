# -*- encoding: utf-8 -*-

class Hive::Utilities::ObserverBase

  attr :subject

  # can implement notify( subject, *details )
  # or can use this implementation

  # It is possible but unlikely that I would want an observer to observe multiple subjects.
  def focus( subject )
    @subject = subject
  end

  def notify( subject, *details )
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

end # Hive::Utilities::ObserverBase
