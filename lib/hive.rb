require "hive/version"

module Hive
  autoload :Configuration,  "hive/configuration"
  autoload :Daemon,         "hive/daemon"
  autoload :Idler,          "hive/idler"
  autoload :Log,            "hive/log"
  autoload :Policy,         "hive/policy"
  autoload :PollingColony,  "hive/polling_colony"
  autoload :Pool,           "hive/pool"
  autoload :ProcessStorage, "hive/process_storage"
  autoload :SimpleColony,   "hive/simple_colony"
  autoload :ThreadedColony, "hive/threaded_colony"
  autoload :Worker,         "hive/worker"
end

module Hive::Utilities
  autoload :AirbrakeObserver, "hive/utilities/airbrake_observer"
  autoload :HoptoadObserver,  "hive/utilities/hoptoad_observer"
  autoload :LogObserver,      "hive/utilities/log_observer"
  autoload :NullJob,          "hive/utilities/null_job"
  autoload :NullObserver,     "hive/utilities/null_observer"
  autoload :Observeable,      "hive/utilities/observeable"
  autoload :Observer,         "hive/utilities/observer"
  autoload :Process,          "hive/utilities/process"
  autoload :SignalHook,       "hive/utilities/signal_hook"
end

module Hive::Redis
  autoload :Colony,         "hive/redis/colony"
  autoload :Observer,       "hive/redis/observer"
  autoload :Storage,        "hive/redis/storage"
end
