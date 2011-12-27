# -*- encoding: utf-8 -*-

# This file is evaluated in the context of a Collective::Configuration instance.
# DSL attributes include: env, set_env, name, set_name (best to set these via command options)
# DSL methods include: chdir, add_path, set_defaults, add_pool, after_fork.

add_path File.dirname(__FILE__)
require "job1"

set_env   "development" if ! env
set_name  "demo"
chdir     "/tmp/demo"

set_defaults(
  pool_min_workers:     1,
  worker_late:          10,
  worker_hung:          100,
  batchsize:            100,
  worker_max_lifetime:  3600
)

add_pool Job1,
  worker_late:          60,
  pool_min_workers:     1,
  pool_max_workers:     10

after_fork do
  # reset ActiveRecord and other pools
  puts "Forked!"
end
