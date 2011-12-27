# -*- encoding: utf-8 -*-

require "helper"

describe Collective::Mocks::Storage do
  
  before do
    @it = Collective::Mocks::Storage.new
  end
  
  it "should be concrete" do
    @it.should_not be_nil
  end
  
  describe "simple values" do
    
    before do
      @it.put("foo","bar")
    end
    
    it "should be settable" do
      @it.get("foo").should eq("bar")
    end
    
    it "should be replaceable" do
      @it.put("foo","goo")
      @it.get("foo").should eq("goo")
    end
    
    it "should be deleteable" do
      @it.get("foo").should_not be_nil
      @it.del("foo")
      @it.get("foo").should be_nil
    end
    
  end # simple values
  
  describe "lists" do
    
    before do
      @it.set_add("foos","A")
    end
    
    it "should not add to a list twice" do
      @it.set_add("foos","A")
      @it.set_size("foos").should eq 1
    end
    
    it "should be able to add to, enumerate, and remove from a list" do
      @it.set_add("foos","B")
      @it.set_size("foos").should eq 2
      @it.set_get_all("foos").should be_include("B")
      @it.set_remove("foos","A")
      @it.set_size("foos").should eq 1
    end

    it "can detect membership in a list" do
      @it.set_add("foos","A")
      @it.set_member?("foos","A").should be_true
    end

  end # lists
  
  describe "maps" do
    
    before do
      @it.map_set("good","A","E")
      @it.map_set("food","A","B")
      @it.map_set("food","C","D")
    end
    
    it "should count a set in a key as one item" do
      @it.map_size("food").should eq 2
      @it.map_size("good").should eq 1
    end
    
    it "should retain the set" do
      @it.map_get("food","A").should eq "B"
      @it.map_get("food","C").should eq "D"
      @it.map_get("good","A").should eq "E"
    end
    
    it "should add to the set" do
      @it.map_get_all_keys("food").size.should eq 2
    end
    
    it "should delete the set" do
      @it.del("food")
      @it.map_size("food").should eq 0
    end
    
  end # maps
  
  describe "priority queues" do

    it "can add items and remove them in order" do
      @it.queue_add "foo", "A", 1
      @it.queue_add "foo", "C", 3
      @it.queue_add "foo", "B", 2
      @it.queue_pop("foo",0).should eq(nil)
      @it.queue_pop("foo",9).should eq("A")
      @it.queue_pop("foo",9).should eq("B")
      @it.queue_pop("foo",9).should eq("C")
    end

  end

end
