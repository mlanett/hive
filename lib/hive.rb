require "hive/version"

module Hive
  autoload :Common,         "hive/common"
  autoload :Configuration,  "hive/configuration"
  autoload :Daemon,         "hive/daemon"
  autoload :Feedback,       "hive/feedback"
  autoload :Idler,          "hive/idler"
  autoload :Log,            "hive/log"
  autoload :Policy,         "hive/policy"
  autoload :PollingColony,  "hive/polling_colony"
  autoload :Pool,           "hive/pool"
  autoload :ProcessStorage, "hive/process_storage"
  autoload :SignalHook,     "hive/signal_hook"
  autoload :SimpleColony,   "hive/simple_colony"
  autoload :ThreadedColony, "hive/threaded_colony"
  autoload :Worker,         "hive/worker"
end

module Hive::Redis
  autoload :Colony,         "hive/colony"
  autoload :Observer,       "hive/observer"
  autoload :Storage,        "hive/storage"
end
