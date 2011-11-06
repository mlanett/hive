# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Idler do

  it "should not run idle tasks too much" do
    count  = 0
    Hive::Idler.wait_until { count += 1; false }
    count.should be <= 10
  end

end
