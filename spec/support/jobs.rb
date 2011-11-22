# -*- encoding: utf-8 -*-

require "support/redis"

class QuitJob
  def call( context = {} )
    context[:worker].quit!
  end
end

class TrueJob
  def call
    true
  end
end

class QuitJobWithSet
  include RedisClient
  def call( context = {} )
    redis.set("QuitJobWithSet",Process.pid)
    context[:worker].quit!
  end
end

class ForeverJobWithSet
  include RedisClient
  def call( context = {} )
    redis.set("ForeverJobWithSet",Process.pid)
    false
  end
end

class ForeverUntilQuitJob
  include RedisClient
  def call( context = {} )
    if redis.get("ForeverUntilQuitJob") then
      context[:worker].quit!
    else
      false
    end
  end
end
