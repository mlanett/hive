# -*- encoding: utf-8 -*-

=begin

$storage.client.reconnect # reconnect() is NOT lazy, must catch errors
worker = Hive::Worker.new( :name => name, &block )
worker.feedback = Hive::Feedback.new($storage)

=end

class Hive::Redis::Feedback
  
  attr_reader :key, :keyh, :keyq
  attr :redis
  
  def initialize(redis = $redis )
    key = $0
    @keyh  = "processor:#{key}:heartbeat"
    @keyq  = "processor:#{key}:queue"
    @redis = redis
  end
  
  def started()
    redis.sadd( "processors", key )
    logger.info "Started"
    heartbeat
  end
  
  def heartbeat()
    redis.set( keyh, Time.now.to_i )
  end
  
  def processed()
    # XXX enqueue message or set status somewhere
    logger.info "Processed"
  end
  
  def error(e)
    logger.error e
    Airbrake.notify(e) unless rack_env == "development"
  end
  
  def stopped()
    redis.multi do
      redis.sdel( "processors", key )
      redis.del( keyh )
      # redis.del( keyq ) probably not right
    end
    logger.info "Stopped"
  end

  # Return false if nothing to do
  def process( &block )
    processed =
    begin
      yield
    rescue StandardError => e
      error(e)
      true
    end
    heartbeat
    processed
  end
  
  #-----------------------------------------------------------------------------
  protected
  #-----------------------------------------------------------------------------
  
  def enqueue( message )
    message = JSON.generate(message)
    redis.rpush( keyq, message )
  end
  
  def dequeue()
    message = redis.lpop( keyq )
    JSON.parse(message) if message
  end
  
end # Hive::Redis::Feedback
