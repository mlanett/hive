require "hive/version"

module Hive
  autoload :RedisColony, "hive/redis_colony"
  autoload :SimpleColony, "hive/simple_colony"
  autoload :ThreadedColony, "hive/threaded_colony"
  
  autoload :Log, "hive/log"
end
