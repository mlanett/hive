File.expand_path(File.dirname(__FILE__)+"/../lib").tap { |d| $: << d unless $:.member?(d) }
require "collective"
require "collective/squiggly"
require "redis"

redis   = Redis.connect url: "redis://127.0.0.1:6379/0"
storage = Collective::Redis::Storage.new(redis)

storage.del "Names"
storage.del "Activity"
storage.del "Weight"
storage.del "Next"

(1..1000).each do |i|
  name     = Squiggly.subject
  activity = rand(1000)

  storage.map_set "Names", "Page-#{i}", name
  storage.map_set "Activity", "Page-#{i}", activity

  storage.queue_add( "Next", "Page-#{i}", 0 )
end
