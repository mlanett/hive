require "hive/version"

module Hive
  autoload :Common,         "hive/common"
  autoload :Daemon,         "hive/daemon"
  autoload :Idler,          "hive/idler"
  autoload :Log,            "hive/log"
  autoload :Policy,         "hive/policy"
  autoload :PollingColony,  "hive/polling_colony"
  autoload :ProcessStorage, "hive/process_storage"
  autoload :SignalHook,     "hive/signal_hook"
  autoload :SimpleColony,   "hive/simple_colony"
  autoload :ThreadedColony, "hive/threaded_colony"
end

module Hive::Redis
  autoload :Colony,         "hive/colony"
  autoload :Observer,       "hive/observer"
  autoload :Storage,        "hive/storage"
end
