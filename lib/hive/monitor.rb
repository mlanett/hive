# -*- encoding: utf-8 -*-
require 'ruby-debug'

class Hive::Monitor

  include Hive::Log

  attr :pools

  def initialize( configuration )
    @pools = configuration.jobs.map do |kind,options|
      pool = Hive::Pool.new( kind, Hive::Policy.resolve(options) )
    end
  end


  def monitor
    job = Hive::Idler.new( nil, min_sleep: 1, max_sleep: 10 ) { check_job }

    @ok = true
    while @ok do
      job.call
    end
  end # monitor


  def check_job
    pools.each do |pool|
      log pool.name
      pool.synchronize
    end
    false
  end

end
