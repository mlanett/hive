require "collective"
require "collective/checker"

=begin

  Sometimes does something but is slow.

=end

class Job3

  attr :redis
  attr :storage

  def initialize( options = {} )
    @redis   = Redis.connect url: "redis://127.0.0.1:6379/0"
    @storage = Collective::Redis::Storage.new(redis)
  end

  include Collective::Log

  def call(context)
    page           = storage.queue_pop( "Next" )
    activity_count = storage.map_get "Activity", page
    last_time      = storage.map_get( "Last", page )
    start          = Time.now
    checker        = Checker.new activity_count, last_time, start
    begin
      return if ! checker.check? # executes ensure block

      log "Processing #{page} with activity #{checker.activity_count}; estimated delay #{checker.estimated_delay} sec"

      sleep(checker.estimated_delay)
      # checker.checked(rand)

      log "Processed #{page}; updated activity count to #{checker.activity_count}; estimated next time #{checker.next_time}"

      storage.map_set "Last", page, start.to_i
    ensure
      storage.queue_add( "Next", page, checker.next_time )
    end
  end

end # Job3
