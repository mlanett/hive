# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Key do

  it "can make keys" do
    name = "processor"
    pid  = 1234
    host = "foo.example.com"
    Hive::Key.new( name, pid, host ).to_s.should eq("processor-1234@foo.example.com")
  end

  it "can parse keys" do
    Hive::Key.parse("processor-1234@foo.example.com").should eq(Hive::Key.new( "processor", "1234", "foo.example.com" ))
    Hive::Key.parse("test-job-1234@foo.example.com").should eq(Hive::Key.new( "test-job", "1234", "foo.example.com" ))
  end

  it "can compare to another key" do
    key1 = Hive::Key.new "Alpha", 1234, "example.com"
    key2 = Hive::Key.new "Alpha", 1234, "example.com"
    key1.should eq(key2)

    key1 = Hive::Key.new "Alpha", 1234, "example.com"
    key2 = Hive::Key.new "Alpha", "1234", "example.com"
    key1.should eq(key2)

    key1 = Hive::Key.new "Alpha", 1234, "example.com"
    key2 = Hive::Key.new "Beta", 1234, "example.com"
    key1.should_not eq(key2)

    key1 = Hive::Key.new "Alpha", 1234, "example.com"
    key2 = Hive::Key.new "Alpha", 2345, "example.com"
    key1.should_not eq(key2)

    key1 = Hive::Key.new "Alpha", 1234, "example.com"
    key2 = Hive::Key.new "Alpha", 1234, "example.org"
    key1.should_not eq(key2)
  end

end
