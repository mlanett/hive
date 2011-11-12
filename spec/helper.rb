# -*- encoding: utf-8 -*-

=begin
@see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/be-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/equality-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/operator-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/predicate-matchers
=end

require "bundler/setup"                                                               # set up gem paths
require "ruby-debug"                                                                  # because sometimes you need it
require "hive"                                                                        # load this gem
require "redis"                                                                       # required by RedisClient

REDIS = { :url => "redis://127.0.0.1:6379/1" }

module RedisClient
  def redis
    @redis ||= begin
      # debugger
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
end

RSpec.configure do |spec|
  # @see https://www.relishapp.com/rspec/rspec-core/docs/helper-methods/define-helper-methods-in-a-module
  spec.include RedisClient, :redis => true

  # nuke the Redis database around each run
  # @see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
  spec.around( :each, :redis => true ) do |example|
    with_clean_redis { example.run }
  end
end
