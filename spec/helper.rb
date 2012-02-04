# -*- encoding: utf-8 -*-

=begin
@see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/be-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/equality-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/operator-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/predicate-matchers
=end

require "bundler/setup"       # set up gem paths
#require "ruby-debug"          # because sometimes you need it

#require "simplecov"           # code coverage
#SimpleCov.start               # must be loaded before our own code

require "hive"                # load this gem
require "support/jobs"        # simple helpers for testing
require "support/redis"       # simple helpers for testing
require "support/timing"      # simple helpers for testing

RSpec.configure do |spec|
  # @see https://www.relishapp.com/rspec/rspec-core/docs/helper-methods/define-helper-methods-in-a-module
  spec.include RedisClient, redis: true
  spec.include Timing, time: true
  spec.include Hive::Idler::Utilities

  # nuke the Redis database around each run
  # @see https://www.relishapp.com/rspec/rspec-core/docs/hooks/around-hooks
  spec.around( :each, redis: true ) do |example|
    with_clean_redis { example.run }
  end
end
