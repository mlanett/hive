# -*- encoding: utf-8 -*-

=begin

  A Worker is a forked process which runs jobs.
  Jobs are short lived and run repeatedly.

=end

class Hive::Worker

  include Hive::Utilities::Observeable
  extend Hive::Utilities::Process

  # forks a new process
  # creates a new instance of the job class
  # runs a loop which calls the job
  def self.spawn( *arguments, &proc )
    fork_and_detach do
      new( *arguments, &proc ).run
    end
  end

  attr :policy
  attr :job
  attr :state

  def initialize( job, policy = Hive::Policy.new, &callable_job )
    job     = resolve_job( job, &callable_job )
    @policy = policy
    @job    = Hive::Idler.new( job, :min_sleep => policy.worker_idle_min_sleep, :max_sleep => policy.worker_idle_max_sleep )

    # set up observers
    policy.observers.each do |observer|
      o = Hive::Utilities::Observer.resolve(observer)
      add_observer(o)
    end

    @state         = :running
    @worker_jobs   = 0
    @worker_expire = Time.now + policy.worker_max_lifetime
    trap("TERM") { quit! }
  end

  def run()
    notify :worker_started
    while state == :running do
      call_job_with_checks
    end
  ensure
    notify :worker_stopped
  end

  def quit!()
    @state = :quitting
  end

  protected

  def call_job_with_checks
    call_job
  ensure
    @worker_jobs += 1
    @state = :quitting if policy.worker_max_jobs <= @worker_jobs
    @state = :quitting if @worker_expire <= Time.now
  end

  def call_job
    context = { :worker => self }
    begin
      job.call( context )
    rescue => x
      notify :job_error, x
    ensure
      notify :worker_heartbeat
    end
  end

  def resolve_job( job, &callable_job )
    raise if job && callable_job
    job ||= callable_job
    if ! job.respond_to?(:call) && job.respond_to?(:new) then
      job = job.new
    end
    raise unless job.respond_to?(:call)
    job
  end

end # Hive::Worker
