# -*- encoding: utf-8 -*-
# This file is evaluated in the context of a Hive::Configuration instance.
# DSL attributes include: env, env=
# DSL methods include: chdir, add_path, set_defaults, add_pool, before_fork, after_fork.

add_path File.dirname(__FILE__)
require "job1"

set_defaults(
  pool_min_workers: 1,
  warntime:         10,
  killtime:         100,
  batchsize:        100,
  lifetime:         3600
)

add_pool Job1,
  heartbeat:        60,
  pool_min_workers: 1,
  pool_max:         10

before_fork do
  # load Rails
  puts "Forking…"
end

after_fork do
  # reset ActiveRecord and other pools
  puts "Forked!"
end