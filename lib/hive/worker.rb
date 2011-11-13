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
      worker = new( *arguments, &proc )
      trap("TERM") { worker.quit! }
      worker.run
    end
  end

  attr :policy
  attr :registry
  attr :job
  attr :state
  attr :worker_jobs
  attr :worker_expire

  def initialize( job = nil, policy = Hive::Policy.new, registry = Hive::Registry.new )
    job       = resolve_job( job )
    @policy   = policy
    @registry = registry
    @job      = Hive::Idler.new( job, :min_sleep => policy.worker_idle_min_sleep, :max_sleep => policy.worker_idle_max_sleep )

    # set up observers
    policy.observers.each do |observer|
      o = Hive::Utilities::ObserverBase.resolve(observer)
      add_observer(o)
    end

    @state         = :running
    @worker_jobs   = 0
    @worker_expire = Time.now + policy.worker_max_lifetime
  end

  def run()
    registry.with_registration(self.key) do
      notify :worker_started
      begin
        while state == :running do
          call_job_with_checks
        end
      ensure
        notify :worker_stopped
      end
    end
  end

  def quit!()
    @state = :quitting
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def call_job_with_checks
    call_job
  ensure
    @worker_jobs += 1
    quit! if policy.worker_max_jobs <= worker_jobs
    quit! if worker_expire <= Time.now
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

  def resolve_job( job )
    raise if ! job

    case job
    when Proc
      job
    when String, Symbol
      resolve_job(Hive.resolve_class(job.to_s))
    else
      case
      when job.respond_to?(:call)
        job
      when job.respond_to?(:new)
        resolve_job(job.new)
      else
        raise "Unknown kind of job #{job.inspect}"
      end
    end
  end

  # the key is a non-changing string which uniquely identifies this worker
  def key
    @key ||= begin
      name     = :unknown
      pid      = Process.pid
      hostname = `hostname`.chomp.strip    # e.g. foo.example.com
      "%s-%i@%s" % [ name, pid, hostname ] # e.g. processor-1234@foo.example.com
    end
  end

  def key=( key )
    raise if @key
    @key = key
  end

end # Hive::Worker
