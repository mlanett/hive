# -*- encoding: utf-8 -*-

require "helper"

describe Collective::Policy do
  
  it "should have defaults" do
    p = Collective::Policy.resolve
    p.worker_max_jobs.should eq(100)
  end

  it "should be changeable" do
    p = Collective::Policy.resolve worker_max_jobs: 5
    p.worker_max_jobs.should eq(5)
  end

  it "should work with symbols" do
    p = Collective::Policy.resolve worker_max_jobs: 5
    p.worker_max_jobs.should eq(5)
  end

  it "should support observers" do
    o = Collective::Utilities::ObserverBase.new
    p = Collective::Policy.resolve observers: [o]
    p.observers.should eq([o])
  end

  it "is copied from another policy" do
    p1 = Collective::Policy.resolve worker_max_jobs: 7, worker_max_lifetime: 999
    p2 = Collective::Policy.resolve policy: p1, worker_max_jobs: 12

    p2.worker_max_lifetime.should eq(p1.worker_max_lifetime)
    p1.worker_max_jobs.should eq(7)
    p2.worker_max_jobs.should eq(12)
  end

  it "can resolve storage" do
    p = Collective::Policy.resolve storage: nil
    s = p.storage
    s.should be_instance_of(Collective::Mocks::Storage)
  end

end
