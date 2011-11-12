# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Policy do
  
  it "should have defaults" do
    p = Hive::Policy.new
    p.worker_max_jobs.should eq(100)
  end

  it "should be changeable" do
    p = Hive::Policy.new "worker_max_jobs" => 5
    p.worker_max_jobs.should eq(5)
  end

  it "should work with symbols" do
    p = Hive::Policy.new :worker_max_jobs => 5
    p.worker_max_jobs.should eq(5)
  end

  it "should support observers" do
    o = NullObserver.new
    p = Hive::Policy.new :observers => [o]
    p.observers.should eq([o])
  end

end
