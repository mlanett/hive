# -*- encoding: utf-8 -*-

=begin
@see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/be-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/equality-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/operator-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/predicate-matchers
=end

require "bundler/setup"       # set up gem paths
require "ruby-debug"          # because sometimes you need it

#require "simplecov"           # code coverage
#SimpleCov.start               # must be loaded before our own code

require "hive"                # load this gem
require "redis"               # required by RedisClient

Hive.default_storage = Hive::Mocks::Storage.new

REDIS = { :url => "redis://127.0.0.1:6379/1" }

module Timing

  def time(&block)
    _time(&block)
    elapsed
  end

  protected

  def start
    @start = Time.now.to_f
  end

  def finish
    @finish = Time.now.to_f
  end

  def elapsed
    @finish - @start
  end

  def _time(&block)
    # elapsed time should be known whether or not it raises an error
    start
    yield
  ensure
    finish
  end

end # Timing

module RedisClient

  def redis
    @redis ||= begin
      ::Redis.connect(REDIS)
    end
  end

  def with_clean_redis(&block)
    redis.flushall
    yield
  ensure
    redis.flushall
    redis.quit
  end

  def with_default_client( before_default_storage = Hive.default_storage, &block)
    Hive.default_storage = Hive::Redis::Storage.new
    yield
  ensure
    Hive.default_storage = before_default_storage
  end

end # RedisClient

RSpec.configure do |spec|
  # @see https://www.relishapp.com/rspec/rspec-core/docs/helper-methods/define-helper-methods-in-a-module
  spec.include RedisClient, :redis => true
  spec.include Timing, :time => true
  spec.include Hive::Idler::Utilities

  # nuke the Redis database around each run
  # @see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
  spec.around( :each, redis: true ) do |example|
    with_default_client { with_clean_redis { example.run } }
  end
end

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
