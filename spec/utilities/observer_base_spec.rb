# -*- encoding: utf-8 -*-

require "helper"
require "hive"

class TestObserver < Hive::Utilities::ObserverBase
  attr :alpha
  attr :beta
  def initialize( alpha = 1, beta = 2 )
    @alpha = alpha
    @beta = beta
  end
end

describe Hive::Utilities::ObserverBase do

  it "can instaniate from a class name" do
    o = Hive::Utilities::ObserverBase.resolve TestObserver
    o.should be_instance_of TestObserver
    o.alpha.should eq(1)
    o.beta.should eq(2)
  end

  it "can instaniate from a string" do
    o = Hive::Utilities::ObserverBase.resolve "TestObserver"
    o.should be_instance_of TestObserver
    o.alpha.should eq(1)
    o.beta.should eq(2)
  end

  it "can instaniate from a block" do
    o = Hive::Utilities::ObserverBase.resolve (->() { TestObserver.new })
    o.should be_instance_of TestObserver
    o.alpha.should eq(1)
    o.beta.should eq(2)
  end

  it "can instaniate from an array" do
    o = Hive::Utilities::ObserverBase.resolve [ TestObserver, 2, 4 ]
    o.should be_instance_of TestObserver
    o.alpha.should eq(2)
    o.beta.should eq(4)
  end
  
end
