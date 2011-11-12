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
  attr :job_with_idle
  attr :state

  def initialize( job, policy = Hive::Policy.new, &callable_job )
    job ||= callable_job
    if ! job.respond_to?(:call) then
      job = job.new
    end
    @policy        = policy
    @job_with_idle = Hive::Idler.new(job)

    # set up observers
    policy.observers.each do |observer|
      o = Hive::Utilities::Observer.resolve(observer)
      add_observer(o)
    end

    @state         = :running
    trap("TERM") { quit! }
  end

  def run()
    job_count = 0
    notify :worker_started
    context = { :worker => self }
    while state == :running do

      call_job( context )

      job_count += 1
      if policy.worker_max_jobs && job_count >= policy.worker_max_jobs then
        @state = :stopped
      end

    end
  ensure
    notify :worker_stopped
  end

  def quit!()
    @state = :quitting
  end

  protected

  def call_job( context )
    begin
      job_with_idle.call( context )
    rescue => x
      notify :job_error, x
    ensure
      notify :heartbeat
    end
  end

end # Hive::Worker
