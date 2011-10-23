# -*- encoding: utf-8 -*-

=begin

  A Worker is a forked process which runs jobs.
  Jobs are short lived and run repeatedly.

=end

class Hive::Worker

  include Hive::Utilities::Observeable

  # forks a new process
  # creates a new instance of the job class
  # runs a loop which calls the job
  def self.spawn( *arguments )
    fork do
      STDIN.reopen "/dev/null"
      trap("TERM") { quit! }
      new( *arguments ).run
    end
  end

  attr :policy
  attr :job_with_idle
  attr :state

  def initialize( options = {}, job, &callable_job )
    job ||= callable_job
    @policy            = Hive::Policy.new(options)
    @job_with_idle     = Hive::Idler.new(job)
    @state             = :running
  end

  def run()
    notify :worker_started
    context = { :worker => self }
    while state == :running do

      begin
        job_with_idle.call( context )
      rescue => x
        notify :job_error, x
        # consume this exception
      ensure
        notify :heartbeat
      end

    end
  ensure
    notify :worker_stopped
  end

  def quit!()
    @state = :quitting
  end

end # Hive::Worker
