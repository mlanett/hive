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

class ListenerJob
  include RedisClient

  def initialize( context = {} )
    storage = Hive::Redis::Storage.new(redis)
    @mq = Hive::Messager.new( storage, my_address: context[:worker].key )
    @mq.expect("Quit")   { |message| context[:worker].quit! }
    @mq.expect("Exit!")  { |message| Kernel.exit! }
    @mq.expect("State?") { |message| @mq.reply "State: #{context[:worker].state}", to: message }
  end

  def call( context = {} )
    @mq.receive
  end
end
