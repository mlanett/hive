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
    options = { stdout: "/tmp/debug.log" }
    Hive::Utilities::Process.fork_and_detach( options ) do
      worker = new( *arguments )
      trap("TERM") { worker.quit! }
      worker.run
    end
  end

  attr :job
  attr :name
  attr :policy
  attr :registry
  attr :state
  attr :worker_expire
  attr :worker_jobs

  # @param options[:name] is optional
  # @param options[:policy] is optional
  # @param options[:registry] is optional
  def initialize( prototype_job, options = nil )
    @registry = options && options[:registry] || Hive::Registry.new("Mock")
    @policy   = options && options[:policy] || Hive::Policy.resolve
    @name     = options && options[:name] || policy.name || prototype_job.to_s
    @job      = Hive::Idler.new( resolve_job( prototype_job ), :min_sleep => policy.worker_idle_min_sleep, :max_sleep => policy.worker_idle_max_sleep )

    # type checks
    policy.pool_min_workers
    registry.workers

    # set up observers
    policy.observers.each do |observer|
      o = Hive::Utilities::ObserverBase.resolve(observer)
      add_observer(o)
    end

    # manage the registry via an observer
    add_observer( Hive::LifecycleObserver.new( key, registry ) )
  end

  def run()
    @state         = :running
    @worker_jobs   = 0
    @worker_expire = Time.now + policy.worker_max_lifetime

    context = { :worker => self }
    with_start_and_stop do
      while running? do
        with_quitting_checks do
          with_heartbeat do
            job.call(context)
          end
        end
      end
    end
  end

  def quit!()
    @state = :quitting
  end

  def running?
    state == :running
  end

  def to_s
    %Q[Worker(#{Process.pid}-#{name})]
  end

  # the key is a constant string which uniquely identifies this worker
  # WARNING this would be invalidated if we forked or set this before forking
  def key
    @key ||= begin
      Hive::Key.new( name, Process.pid )
    end
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def with_start_and_stop(&block)
    notify :worker_started
    begin
      yield
    ensure
      notify :worker_stopped
    end
  end

  def with_quitting_checks(&block)
    yield
  ensure
    @worker_jobs += 1
    quit! if policy.worker_max_jobs <= worker_jobs
    quit! if worker_expire <= Time.now
  end

  def with_heartbeat(&block)
    begin
      yield
    rescue => x
      notify :job_error, x
    ensure
      notify :worker_heartbeat
    end
  end

  def resolve_job( job_prototype )
    raise if ! job_prototype

    case job_prototype
    when Proc
      job_prototype
    when String, Symbol
      resolve_job(Hive.resolve_class(job_prototype.to_s))
    else
      case
      when job_prototype.respond_to?(:call)
        job_prototype
      when job_prototype.respond_to?(:new)
        resolve_job(job_prototype.new)
      else
        raise "Unknown kind of job #{job_prototype.inspect}"
      end
    end
  end

end # Hive::Worker
