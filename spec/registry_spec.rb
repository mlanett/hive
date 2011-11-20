# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Registry do

  it "can register a worker" do
    storage  = Hive::Mocks::Storage.new
    registry = Hive::Registry.new(storage)
    worker   = double("Worker")
    registry.register(worker)
    registry.workers.should be_include(worker)
  end

  it "can unregister a worker" do
    storage  = Hive::Mocks::Storage.new
    registry = Hive::Registry.new(storage)
    worker   = double("Worker")
    registry.register(worker)
    registry.workers.should be_include(worker)
    registry.unregister(worker)
    registry.workers.should_not be_include(worker)
  end

  it "can find live workers"

  it "can find late workers"

  it "can find dead workers"

  describe "keys" do

    it "can make keys" do
      name = "processor"
      pid  = 1234
      host = "foo.example.com"
      Hive::Registry.make_key( name, pid, host ).should eq("processor-1234@foo.example.com")
    end

    it "can parse keys" do
      Hive::Registry.parse_key("processor-1234@foo.example.com").should eq(Hive::Registry::Entry.new( "processor", "1234", "foo.example.com" ))
      Hive::Registry.parse_key("test-job-1234@foo.example.com").should eq(Hive::Registry::Entry.new( "test-job", "1234", "foo.example.com" ))
    end

  end

end
