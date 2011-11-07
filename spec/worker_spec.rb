# -*- encoding: utf-8 -*-

require "helper"

class Hive::SpawningJob
  include RedisClient
  def initialize
    redis.set("Hive::SpawningJob",Process.pid)
  end
  def call( context = {} )
    context[:worker].quit!
  end
end

class Hive::TermJob
  include RedisClient
  def initialize
    redis.set "Hive::TermJob", Process.pid
  end
  def call( context = {} )
    false
  end
end

describe Hive::Worker do
  
  it "should run once" do
    count  = 0
    worker = nil
    job    = ->(context={}) { count += 1; worker.quit! }
    worker = Hive::Worker.new( job )
    worker.run
    count.should eq 1
  end

  it "should pass a context with a worker" do
    ok     = false
    worker = nil
    job    = ->(context) { worker.should eq context[:worker]; worker.quit! }
    worker = Hive::Worker.new( job )
    worker.run
  end

  it "should use observers" do
    job     = ->(context) { context[:worker].quit! }
    tracker = Hive::Utilities::NullObserver.new
    policy  = Hive::Policy.new({ :pool_min_workers => 1, :observers => [ tracker ] })
    worker  = Hive::Worker.new( job, policy )

    worker.run
    tracker.notifications.should eq([:worker_started, :heartbeat, :worker_stopped])
  end

  describe "when spawning a process", :redis => true do

    it "should spawn a new process" do
      pid   = Process.pid
      redis.set "Hive::SpawningJob", pid

      Hive::Worker.spawn( Hive::SpawningJob )
      Hive::Idler.wait_until { redis.get("Hive::SpawningJob").to_i != pid }
      redis.get("Hive::SpawningJob").to_i.should_not eq(pid)
      redis.del "Hive::SpawningJob"
    end

    it "should respond to TERM" do
      redis.del "Hive::TermJob"

      Hive::Worker.spawn( Hive::TermJob )
      Hive::Idler.wait_until { redis.get("Hive::TermJob").to_i != 0 }
      pid = redis.get("Hive::TermJob").to_i
      Hive::Utilities::Process.alive?(pid).should be_true

      Process.kill( "TERM", pid )
      Hive::Idler.wait_until { ! Hive::Utilities::Process.alive?(pid) }
      Hive::Utilities::Process.alive?(pid).should be_false

      redis.del "Hive::TermJob"
    end

  end

end
