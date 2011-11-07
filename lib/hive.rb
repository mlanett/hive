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
  autoload :AirbrakeFeedback, "hive/utilities/airbrake_feedback"
  autoload :HoptoadFeedback,  "hive/utilities/hoptoad_feedback"
  autoload :LogFeedback,      "hive/utilities/log_feedback"
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
