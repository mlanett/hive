require "hive/version"

module Hive
  autoload :PollingColony,  "hive/polling_colony"
  autoload :RedisColony,    "hive/redis_colony"
  autoload :SimpleColony,   "hive/simple_colony"
  autoload :ThreadedColony, "hive/threaded_colony"
  
  autoload :Common,         "hive/common"
  autoload :Idler,          "hive/idler"
  autoload :Log,            "hive/log"
  autoload :ProcessStorage, "hive/process_storage"
end
