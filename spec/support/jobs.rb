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
    @rpc = Hive::Messager.new( storage, my_address: context[:worker].key )
    @rpc.expect("Quit")   { |message| context[:worker].quit! }
    @rpc.expect("Exit!")  { |message| Kernel.exit! }
    @rpc.expect("State?") { |message| @rpc.reply "State: #{context[:worker].state}", to: message }
  end

  def call( context = {} )
    @rpc.receive
  end
end
