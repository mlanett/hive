=begin
must_be                o1, op, o2, msg = nil
must_be_close_to       exp, act, delta = 0.001, msg = nil
must_be_empty          obj, msg = nil
must_be_instance_of    cls, obj, msg = nil
must_be_kind_of        cls, obj, msg = nil
must_be_nil            obj, msg = nil
must_be_same_as        assert_same
must_be_silent         
must_be_within_delta   exp, act, delta = 0.001, msg = nil
must_be_within_epsilon a, b, epsilon = 0.001, msg = nil
must_equal             exp, act, msg = nil
must_include           collection, obj, msg = nil
must_match             exp, act, msg = nil
must_output            stdout = nil, stderr = nil
must_raise             *exp
must_respond_to        obj, meth, msg = nil
must_send              exp, act, msg = nil
must_throw             sym, msg = nil
=end

require "bundler/setup"                                                               # load dependencies
require "ruby-debug"                                                                  # because sometimes you need it
require "minitest/autorun"                                                            # enable minitest
File.expand_path("../../spec", __FILE__).tap { |p| $:.push(p) unless $:.member?(p) }  # set path
require "hive"                                                                        # load this gem

REDIS = { :url => "redis://127.0.0.1:6379/1" }
