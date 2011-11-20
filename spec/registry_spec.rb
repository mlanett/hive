# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Registry do

  it "can register a worker" do
    registry = Hive::Registry.new( "Test" )
    worker   = Hive::Worker.new( TrueJob, registry: registry )

    registry.register( worker.key )
    registry.workers.should be_include( worker.key )
  end

  it "can unregister a worker" do
    registry = Hive::Registry.new( "Test" )
    worker   = Hive::Worker.new( TrueJob, registry: registry )

    registry.register( worker.key )
    registry.workers.should be_include( worker.key )

    registry.unregister( worker.key )
    registry.workers.should_not be_include( worker.key )
  end

  it "can find live workers"

  it "can find late workers"

  it "can find dead workers"

end
