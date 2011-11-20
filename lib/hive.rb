require "hive/version"

module Hive
  autoload :Configuration,    "hive/configuration"
  autoload :Daemon,           "hive/daemon"
  autoload :Idler,            "hive/idler"
  autoload :Key,              "hive/key"
  autoload :LifecycleObserver,"hive/lifecycle_observer"
  autoload :Log,              "hive/log"
  autoload :Policy,           "hive/policy"
  autoload :PollingColony,    "hive/polling_colony"
  autoload :Pool,             "hive/pool"
  autoload :Registry,         "hive/registry"
  autoload :SimpleColony,     "hive/simple_colony"
  autoload :ThreadedColony,   "hive/threaded_colony"
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
end

module Hive::Redis
  autoload :Colony,           "hive/redis/colony"
  autoload :Storage,          "hive/redis/storage"
end

module Hive
  class << self

    # @param classname
    # @returns class object
    def resolve_class(classname)
      classname.split(/::/).inject(Object) { |a,i| a.const_get(i) }
    end

    attr :default_storage

    def default_storage
      @default_storage ||= Hive::Redis::Storage.new
    end

    def default_storage=(default_storage)
      @default_storage = default_storage
    end

  end # class
end

class Hive::ConfigurationError < Exception
end
