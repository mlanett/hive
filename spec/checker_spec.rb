# -*- encoding: utf-8 -*-

require "helper"
require "hive/checker"

describe Checker do

  it "does something" do
    activity_count = 192
    last_time      = Time.now - 3600
    c = Checker.new activity_count, last_time

    c.check?.should_not be_false
    c.estimated_delay.should be >= 1.0
    c.estimated_delay.should be < 8.0

    c.checked 12
  end

end
