# -*- encoding: utf-8 -*-

require "helper"

describe Collective::Registry, redis: true do

  before do
    @policy = Collective::Policy.resolve
  end

  it "can register a worker" do
    registry = Collective::Registry.new( "Test", @policy.storage )
    worker   = Collective::Worker.new( TrueJob, registry: registry )

    registry.register( worker.key )
    registry.workers.should be_include( worker.key )
  end

  it "can unregister a worker" do
    registry = Collective::Registry.new( "Test", @policy.storage )
    worker   = Collective::Worker.new( TrueJob, registry: registry )

    registry.register( worker.key )
    registry.workers.should be_include( worker.key )

    registry.unregister( worker.key )
    registry.workers.should_not be_include( worker.key )
  end

  it "can find live workers" do
    registry  = Collective::Registry.new( "Test", @policy.storage )
    heartbeat = @policy.worker_late / 2
    key       = Collective::Key.new("Test",1234)

    registry.register(key)
    checked = registry.checked_workers(@policy)
    checked.live.should eq([key])
  end

  it "can find late workers" do
    registry  = Collective::Registry.new( "Test", @policy.storage )
    heartbeat = @policy.worker_late
    key       = Collective::Key.new("Test",1234)

    now       = Time.now.to_i
    registry.register(key) # should register with heartbeat = now or now+1
    registry.stub(:now) { now + @policy.worker_late + 2 }
    checked = registry.checked_workers(@policy)
    checked.late.should eq([key])
  end

end
