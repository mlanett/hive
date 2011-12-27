# -*- encoding: utf-8 -*-

require "helper"

describe Collective::Key do

  it "can make keys" do
    name = "processor"
    pid  = 1234
    host = "foo.example.com"
    Collective::Key.new( name, pid, host ).to_s.should eq("processor-1234@foo.example.com")
  end

  it "can parse keys" do
    Collective::Key.parse("processor-1234@foo.example.com").should eq(Collective::Key.new( "processor", "1234", "foo.example.com" ))
    Collective::Key.parse("test-job-1234@foo.example.com").should eq(Collective::Key.new( "test-job", "1234", "foo.example.com" ))
  end

  it "can compare to another key" do
    key1 = Collective::Key.new "Alpha", 1234, "example.com"
    key2 = Collective::Key.new "Alpha", 1234, "example.com"
    key1.should eq(key2)

    key1 = Collective::Key.new "Alpha", 1234, "example.com"
    key2 = Collective::Key.new "Alpha", "1234", "example.com"
    key1.should eq(key2)

    key1 = Collective::Key.new "Alpha", 1234, "example.com"
    key2 = Collective::Key.new "Beta", 1234, "example.com"
    key1.should_not eq(key2)

    key1 = Collective::Key.new "Alpha", 1234, "example.com"
    key2 = Collective::Key.new "Alpha", 2345, "example.com"
    key1.should_not eq(key2)

    key1 = Collective::Key.new "Alpha", 1234, "example.com"
    key2 = Collective::Key.new "Alpha", 1234, "example.org"
    key1.should_not eq(key2)
  end

end
