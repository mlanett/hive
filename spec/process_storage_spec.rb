# -*- encoding: utf-8 -*-

describe Hive::ProcessStorage do
  
  before do
    @it = Hive::ProcessStorage.new
  end
  
  it "should be concrete" do
    @it.wont_be_nil
  end
  
  describe "simple values" do
    
    before do
      @it.put("foo","bar")
    end
    
    it "should be settable" do
      @it.get("foo").must_equal("bar")
    end
    
    it "should be replaceable" do
      @it.put("foo","goo")
      @it.get("foo").must_equal("goo")
    end
    
    it "should be deleteable" do
      @it.get("foo").wont_be_nil
      @it.del("foo")
      @it.get("foo").must_be_nil
    end
    
  end # simple values
  
  describe "lists" do
    
    before do
      @it.set_add("foos","A")
    end
    
    it "should not add to a list twice" do
      @it.set_add("foos","A")
      @it.set_size("foos").must_equal 1
    end
    
    it "should be able to add to, enumerate, and remove from a list" do
      @it.set_add("foos","B")
      @it.set_size("foos").must_equal 2
      @it.set_members("foos").must_include("B")
      @it.set_remove("foos","A")
      @it.set_size("foos").must_equal 1
    end
    
  end # lists
  
  describe "maps" do
    
    before do
      @it.map_set("good","A","E")
      @it.map_set("food","A","B")
      @it.map_set("food","C","D")
    end
    
    it "should count a set in a key as one item" do
      @it.map_size("food").must_equal 2
      @it.map_size("good").must_equal 1
    end
    
    it "should retain the set" do
      @it.map_get("food","A").must_equal "B"
      @it.map_get("food","C").must_equal "D"
      @it.map_get("good","A").must_equal "E"
    end
    
    it "should add to the set" do
      @it.map_get_all("food").size.must_equal 2
    end
    
    it "should delete the set" do
      @it.map_del("food")
      @it.map_size("food").must_equal 0
    end
    
  end # maps
  
end
