require "hive/version"

module Hive
  autoload :Configuration,    "hive/configuration"
  autoload :Idler,            "hive/idler"
  autoload :Key,              "hive/key"
  autoload :LifecycleObserver,"hive/lifecycle_observer"
  autoload :Log,              "hive/log"
  autoload :Messager,         "hive/messager"
  autoload :Monitor,          "hive/monitor"
  autoload :Policy,           "hive/policy"
  autoload :Pool,             "hive/pool"
  autoload :Registry,         "hive/registry"
  autoload :Worker,           "hive/worker"
end

module Hive::Mocks
  autoload :Storage,          "hive/mocks/storage"
end

module Hive::Utilities
  autoload :AirbrakeObserver, "hive/utilities/airbrake_observer"
  autoload :HoptoadObserver,  "hive/utilities/hoptoad_observer"
  autoload :LogObserver,      "hive/utilities/log_observer"
  autoload :NullObserver,     "hive/utilities/null_observer"
  autoload :Observeable,      "hive/utilities/observeable"
  autoload :ObserverBase,     "hive/utilities/observer_base"
  autoload :Process,          "hive/utilities/process"
  autoload :SignalHook,       "hive/utilities/signal_hook"
  autoload :StorageBase,      "hive/utilities/storage_base"
end

module Hive::Redis
  autoload :Storage,          "hive/redis/storage"
end

module Hive
  class << self

    # @param classname
    # @returns class object
    def resolve_class(classname)
      classname.split(/::/).inject(Object) { |a,i| a.const_get(i) }
    end

  end # class
end

class Hive::ConfigurationError < Exception
end
