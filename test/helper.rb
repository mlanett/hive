require "bundler/setup"                                                               # load dependencies
File.expand_path("../../test", __FILE__).tap { |p| $:.push(p) unless $:.member?(p) }  # set path
require "hive"                                                                        # load this gem
