# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Idler do

  it "should accept a proc" do
    idler = Hive::Idler.new() { true }
    expect { idler.call }.to_not raise_error
  end

  it "should accept a lambda" do
    job = ->() { true }
    idler = Hive::Idler.new(job)
    expect { idler.call }.to_not raise_error
  end

  it "should accept an object with an interface" do
    idler = Hive::Idler.new( NullJob.new )
    expect { idler.call }.to_not raise_error
  end

  it "should refuse non-callable jobs" do
    fake_job = Object.new
    expect { Hive::Idler.new(fake_job) }.to raise_error
  end

  it "should not run idle tasks too much" do
    count  = 0
    Hive::Idler.wait_until { count += 1; false }
    count.should be <= 10
  end

  describe "when dealing with sleep times", :time => true do

    it "should not sleep after the first false"

    it "should not sleep too long"

    it "should sleep at least a little"

  end

end
