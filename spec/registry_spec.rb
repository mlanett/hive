# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Registry do

  it "can register a worker" do
    storage  = Hive::ProcessStorage.new
    registry = Hive::Registry.new(storage)
    worker   = double("Worker")
    registry.register(worker)
    registry.workers.should be_include(worker)
  end

  it "can unregister a worker" do
    storage  = Hive::ProcessStorage.new
    registry = Hive::Registry.new(storage)
    worker   = double("Worker")
    registry.register(worker)
    registry.workers.should be_include(worker)
    registry.unregister(worker)
    registry.workers.should_not be_include(worker)
  end

  it "can find live workers"

end
