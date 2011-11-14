# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Policy do
  
  it "should have defaults" do
    p = Hive::Policy.policy
    p.worker_max_jobs.should eq(100)
  end

  it "should be changeable" do
    p = Hive::Policy.policy "worker_max_jobs" => 5
    p.worker_max_jobs.should eq(5)
  end

  it "should work with symbols" do
    p = Hive::Policy.policy :worker_max_jobs => 5
    p.worker_max_jobs.should eq(5)
  end

  it "should support observers" do
    o = Hive::Utilities::ObserverBase.new
    p = Hive::Policy.policy :observers => [o]
    p.observers.should eq([o])
  end

end
