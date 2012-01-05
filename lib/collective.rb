File.expand_path(File.dirname(__FILE__)).tap { |d| $: << d unless $:.member?(d) }

require "collective/version"

module Collective
  autoload :Configuration,    "collective/configuration"
  autoload :Idler,            "collective/idler"
  autoload :Key,              "collective/key"
  autoload :LifecycleObserver,"collective/lifecycle_observer"
  autoload :Log,              "collective/log"
  autoload :Messager,         "collective/messager"
  autoload :Monitor,          "collective/monitor"
  autoload :Policy,           "collective/policy"
  autoload :Pool,             "collective/pool"
  autoload :Registry,         "collective/registry"
  autoload :Trace,            "collective/trace"
  autoload :Worker,           "collective/worker"
end

module Collective::Mocks
  autoload :Storage,          "collective/mocks/storage"
end

module Collective::Redis
  autoload :Storage,          "collective/redis/storage"
end

module Collective::Utilities
  autoload :AirbrakeObserver, "collective/utilities/airbrake_observer"
  autoload :HoptoadObserver,  "collective/utilities/hoptoad_observer"
  autoload :LogObserver,      "collective/utilities/log_observer"
  autoload :NullObserver,     "collective/utilities/null_observer"
  autoload :Observeable,      "collective/utilities/observeable"
  autoload :ObserverBase,     "collective/utilities/observer_base"
  autoload :Process,          "collective/utilities/process"
  autoload :Resolver,         "collective/utilities/resolver"
  autoload :SignalHook,       "collective/utilities/signal_hook"
  autoload :StorageBase,      "collective/utilities/storage_base"
end

class Collective::ConfigurationError < Exception
end
