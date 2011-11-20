# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Worker do

  before do
    @default_policy = Hive::Policy.resolve worker_max_lifetime: 10, worker_max_jobs: 100
  end

  it "should run once" do
    count  = 0
    worker = nil
    job    = ->(context={}) { count += 1; worker.quit! }
    worker = Hive::Worker.new( job )
    worker.run
    count.should eq 1
  end

  it "should run with a classname" do
    worker = Hive::Worker.new("QuitJob")
    expect { worker.run }.should_not raise_error
  end

  it "should run with a class" do
    worker = Hive::Worker.new(QuitJob)
    expect { worker.run }.should_not raise_error
  end

  it "should run with a lambda" do
    job    = ->(context) { context[:worker].quit! }
    worker = Hive::Worker.new( job )
    expect { worker.run }.should_not raise_error
  end

  it "should pass a context with a worker" do
    ok     = false
    worker = nil
    job    = ->(context) { worker.should eq context[:worker]; worker.quit! }
    worker = Hive::Worker.new( job )
    worker.run
  end

  it "should use observers" do
    obsrvr  = Hive::Utilities::ObserverBase.new
    obsrvr.should_receive(:notify).with(anything,:worker_started).ordered
    obsrvr.should_receive(:notify).with(anything,:worker_heartbeat).ordered
    obsrvr.should_receive(:notify).with(anything,:worker_stopped).ordered

    job     = ->(context) { context[:worker].quit! }
    policy  = Hive::Policy.resolve({ :observers => [ obsrvr ] })
    worker  = Hive::Worker.new job, policy: policy

    worker.run
  end

  it "should exit when the policy says to run out (of jobs)" do
    count  = 0
    job    = ->(context) { count += 1; true }
    policy = Hive::Policy.resolve({ "worker_max_jobs" => 5 })
    worker = Hive::Worker.new job, policy: policy
    worker.run
    count.should be <= 5
  end

  describe "when testing lifetime", :time => true do
    it "should exit when the policy says to run out (of time)" do
      overhead = 1
      lifetime = 2
      count    = 0
      job      = ->(context) { count += 1; true }
      policy   = Hive::Policy.resolve({ "worker_max_lifetime" => lifetime, :worker_max_jobs => 1e9 })
      worker   = Hive::Worker.new job, policy: policy
      time { worker.run }
      elapsed.should be <= lifetime + overhead
    end
  end

  describe "when spawning a process", :redis => true do

    it "should spawn a new process" do
      Hive::Worker.spawn( QuitJobWithSet )
      wait_until { redis.get("QuitJobWithSet").to_i > 0 }
      redis.get("QuitJobWithSet").to_i.should be > 0
    end

    it "should respond to TERM" do
      Hive::Worker.spawn( ForeverJobWithSet )

      wait_until { redis.get("ForeverJobWithSet").to_i != 0 }
      pid = redis.get("ForeverJobWithSet").to_i
      Hive::Utilities::Process.alive?(pid).should be_true

      Process.kill( "TERM", pid )
      wait_until { ! Hive::Utilities::Process.alive?(pid) }
      Hive::Utilities::Process.alive?(pid).should be_false
    end

    it "uses the registry" do
      registry = Hive::Registry.new( "Test-#{Process.pid}" )
      registry.workers.size.should eq(0)
      Hive::Worker.spawn ForeverUntilQuitJob, registry: registry, policy: @default_policy

      wait_until { registry.workers.size > 0 }
      registry.workers.size.should eq(1)
      # ["unknown-7119@mark.local"]

      redis.set("ForeverUntilQuitJob",true)
      wait_until { registry.workers.size == 0 }
      registry.workers.size.should eq(0)
    end

  end

  describe "keys" do

    it "can make keys" do
      name = "processor"
      pid  = 1234
      host = "foo.example.com"
      Hive::Worker.make_key( name, pid, host ).should eq("processor-1234@foo.example.com")
    end

    it "can parse keys" do
      Hive::Worker.parse_key("processor-1234@foo.example.com").should eq([ "processor", "1234", "foo.example.com" ])
      Hive::Worker.parse_key("test-job-1234@foo.example.com").should eq([ "test-job", "1234", "foo.example.com" ])
    end

  end

end
