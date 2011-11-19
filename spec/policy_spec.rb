# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Policy do
  
  it "should have defaults" do
    p = Hive::Policy.resolve
    p.worker_max_jobs.should eq(100)
  end

  it "should be changeable" do
    p = Hive::Policy.resolve "worker_max_jobs" => 5
    p.worker_max_jobs.should eq(5)
  end

  it "should work with symbols" do
    p = Hive::Policy.resolve :worker_max_jobs => 5
    p.worker_max_jobs.should eq(5)
  end

  it "should support observers" do
    o = Hive::Utilities::ObserverBase.new
    p = Hive::Policy.resolve :observers => [o]
    p.observers.should eq([o])
  end

  it "is copied from another policy" do
    p1 = Hive::Policy.resolve :worker_max_jobs => 12
    p2 = Hive::Policy.resolve(p1)
    p2.worker_max_jobs.should eq(p1.worker_max_jobs)

    p1.worker_max_jobs = 7
    p2.worker_max_jobs.should eq(12)
  end

end
