# -*- encoding: utf-8 -*-

require "helper"

describe Collective::Worker do

  it "should run once" do
    count  = 0
    worker = nil
    job    = ->(context={}) { count += 1; worker.quit! }
    worker = Collective::Worker.new( job )
    worker.run
    count.should eq 1
  end

  it "should run with a classname" do
    worker = Collective::Worker.new("QuitJob")
    expect { worker.run }.should_not raise_error
  end

  it "should run with a class" do
    worker = Collective::Worker.new(QuitJob)
    expect { worker.run }.should_not raise_error
  end

  it "should run with a lambda" do
    job    = ->(context) { context[:worker].quit! }
    worker = Collective::Worker.new( job )
    expect { worker.run }.should_not raise_error
  end

  it "should pass a context with a worker" do
    ok     = false
    worker = nil
    job    = ->(context) { worker.should eq context[:worker]; worker.quit! }
    worker = Collective::Worker.new( job )
    worker.run
  end

  it "should use observers" do
    obsrvr  = Collective::Utilities::ObserverBase.new
    obsrvr.should_receive(:notify).with(anything,:worker_started).ordered
    obsrvr.should_receive(:notify).with(anything,:worker_heartbeat).ordered
    obsrvr.should_receive(:notify).with(anything,:worker_stopped).ordered

    job     = ->(context) { context[:worker].quit! }
    policy  = Collective::Policy.resolve({ observers: [ obsrvr ] })
    worker  = Collective::Worker.new job, policy: policy

    worker.run
  end

  it "should exit when the policy says to run out (of jobs)" do
    count  = 0
    job    = ->(context) { count += 1; true }
    policy = Collective::Policy.resolve({ worker_max_jobs: 5 })
    worker = Collective::Worker.new job, policy: policy
    worker.run
    count.should be <= 5
  end

  it "should execute after_fork blocks"

  describe "when testing lifetime", time: true do
    it "should exit when the policy says to run out (of time)" do
      overhead = 1
      worker_max_lifetime = 2
      count    = 0
      job      = ->(context) { count += 1; true }
      policy   = Collective::Policy.resolve worker_max_lifetime: worker_max_lifetime, worker_max_jobs: 1e9
      worker   = Collective::Worker.new job, policy: policy
      time { worker.run }
      elapsed.should be <= worker_max_lifetime + overhead
    end
  end

  describe "when spawning a process", redis: true do

    before do
      @policy = Collective::Policy.resolve worker_max_lifetime: 4, worker_max_jobs: 100, storage: :redis
    end

    it "should spawn a new process" do
      Collective::Worker.spawn( QuitJobWithSet )
      wait_until { redis.get("QuitJobWithSet").to_i > 0 }
      redis.get("QuitJobWithSet").to_i.should be > 0
    end

    it "should respond to TERM" do
      Collective::Worker.spawn( ForeverJobWithSet )

      wait_until { redis.get("ForeverJobWithSet").to_i != 0 }
      pid = redis.get("ForeverJobWithSet").to_i
      Collective::Utilities::Process.alive?(pid).should be_true

      Process.kill( "TERM", pid )
      wait_until { ! Collective::Utilities::Process.alive?(pid) }
      Collective::Utilities::Process.alive?(pid).should be_false
    end

    it "uses the registry" do
      job       = ForeverUntilQuitJob
      registry  = Collective::Registry.new( job.to_s, @policy.storage )
      registry.workers.size.should eq(0)

      Collective::Worker.spawn ForeverUntilQuitJob, registry: registry, policy: @policy

      wait_until { registry.workers.size > 0 }
      registry.workers.size.should eq(1)

      key = registry.workers.first
      key.name.should eq(job.to_s)

      redis.set("ForeverUntilQuitJob",true)
      wait_until { registry.workers.size == 0 }
      registry.workers.size.should eq(0)
    end

  end

end
