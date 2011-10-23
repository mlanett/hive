# -*- encoding: utf-8 -*-

=begin

  A Worker is a forked process which runs jobs.
  Jobs are short lived and run repeatedly.

=end

class Hive::Worker

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
  attr :job_with_feedback
  attr :job_with_idle
  attr :state

  def initialize( options = {}, job, &callable_job )
    job ||= callable_job
    @policy            = Hive::Policy.new(options)
    @job_with_feedback = Hive::Feedback.new( self, job )
    @job_with_idle     = Hive::Idler.new(@job_with_feedback)
    @state             = :running
  end

  def run()
    context = { :worker => self }
    #job_with_feedback.with_feedback do
      while state == :running do
        job_with_idle.call( context )
      end
    #end
  end

  def quit!()
    @state = :quitting
  end

end # Hive::Worker
