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
