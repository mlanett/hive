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

  describe "when dealing with sleep times", :time => true do

    it "should not run idle tasks too much" do
      count  = 0
      Hive::Idler.wait_until { count += 1; false }
      count.should be <= 10
    end

    it "should sleep after a failure" do
      job = ->() { false }
      idler = Hive::Idler.new( job, :min_sleep => 0.125 )
      time { idler.call }.should be >= 0.125
    end

    it "should not sleep after a success" do
      result = false
      job    = ->() { result }
      idler  = Hive::Idler.new( job, :min_sleep => 0.125 )
      idler.call
      time { result = true; idler.call }.should be < 0.1
    end

    it "should not sleep too long" do
      job    = ->() { false }
      idler  = Hive::Idler.new( job, :min_sleep => 0.125 )
      time { idler.call }.should be < 0.25
    end

  end

end
