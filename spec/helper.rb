# -*- encoding: utf-8 -*-

=begin
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/be-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/equality-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/operator-matchers
@see https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/predicate-matchers
=end

require "bundler/setup"                                                               # set up gem paths
require "ruby-debug"                                                                  # because sometimes you need it
require "hive"                                                                        # load this gem

RSpec.configure do |spec|
  # spec.include Helpers
end

REDIS = { :url => "redis://127.0.0.1:6379/1" }
