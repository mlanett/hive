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

  # factory_or_observer can be something which responds to #notify
  # or a block which responds to #call and can return a factory_or_observer
  # or a class which can be instantiated
  # or a string which can be resolved to a class
  # or an array which can be resolved to a class with parameters
  def self.resolve( factory_or_observer, *args )
    case
    when factory_or_observer.respond_to?(:notify)
      factory_or_observer
    when factory_or_observer.respond_to?(:call)
      resolve(factory_or_observer.call(*args))
    else
      case factory_or_observer
      when :airbrake
        resolve(Hive::Utilities::AirbrakeObserver,*args)
      when :hoptoad
        resolve(Hive::Utilities::HoptoadObserver,*args)
      when :log
        resolve(Hive::Utilities::LogObserver,*args)
      when Class
        factory_or_observer.new(*args)
      when String
        resolve(Hive.resolve_class(factory_or_observer.to_s),*args)
      when Array
        args = factory_or_observer.dup
        fobs = args.shift
        factory = resolve( fobs, *args )
      else
        return factory_or_observer # assume it supports the notifications natively
      end
    end
  end

  def self.camelize(s)
    s.to_s.gsub(/(?:^|_|\s)(.)/) { $1.upcase }
  end

end # Hive::Utilities::ObserverBase
