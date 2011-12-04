# -*- encoding: utf-8 -*-

require "helper"
require "hive"

describe Hive::Utilities::Process do
  it "does not fail like Process.wait2" do
    system("false")
    pid = $?.pid
    expect { ::Process.wait2( pid ) }.to raise_exception
  end
  it "can handle dead processes" do
    system("false")
    pid = $?.pid
    expect { Hive::Utilities::Process.wait_and_terminate(pid) }.to_not raise_exception
  end
end
