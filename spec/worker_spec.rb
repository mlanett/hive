class Hive::SpawningJob
  def call( context = {} )
    redis.set("Hive::SpawningJob",Process.pid)
    context[:worker].quit
  end
  def redis
    @redis ||= Redis.connect(REDIS)
  end
end

class Hive::QuittingJob
  def call( context = {} )
    if redis.get("Hive::QuittingJob") == "quit" then
      context[:worker].quit!
    else
      false
    end
  end
  def redis
    @redis ||= Redis.connect(REDIS)
  end
end

describe Hive::Worker do
  
  it "should run once" do
    count  = 0
    worker = nil
    job    = ->(context={}) { count += 1; worker.quit! }
    worker = Hive::Worker.new({},job)
    worker.run
    count.must_equal 1
  end

  it "should pass a context with a worker" do
    ok     = false
    worker = nil
    job    = ->(context={}) { worker.must_equal context[:worker]; worker.quit! }
    worker = Hive::Worker.new({},job)
    worker.run
  end

  it "should spawn a new process" do
    pid   = Process.pid
    redis = Redis.connect(REDIS)
    redis.set "Hive::SpawningJob", pid

    Hive::Worker.spawn({},Hive::SpawningJob.new)
    Hive::Idler.wait_until { redis.get("Hive::SpawningJob").to_i != pid }
    redis.get("Hive::SpawningJob").to_i.wont_equal pid
    redis.del "Hive::SpawningJob"
  end

end
