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
  def self.spawn( prototype_job, options = {} )
    policy   = options[:policy] || Hive::Policy.resolve
    name     = options[:name] || policy.name || prototype_job.to_s
    storage  = policy.storage
    registry = options[:registry] || Hive::Registry.new( name, storage )

    foptions = { stdout: "/tmp/debug.log" }
    policy.before_fork
    Hive::Utilities::Process.fork_and_detach( foptions ) do
      policy.after_fork
      # $0 = "$0 #{name}"
      worker = new( prototype_job, options )
      trap("TERM") { worker.quit! }
      worker.run
    end
  end

  attr :job
  attr :name
  attr :policy
  attr :registry
  attr :state
  attr :storage
  attr :worker_expire
  attr :worker_jobs

  # @param options[:name] is optional
  # @param options[:policy] is optional
  # @param options[:registry] is optional
  def initialize( prototype_job, options = {} )
    @policy   = options[:policy] || Hive::Policy.resolve
    @name     = options[:name] || policy.name || prototype_job.to_s
    @storage  = policy.storage
    @registry = options[:registry] || Hive::Registry.new( name, storage )
    @job      = Hive::Idler.new( resolve_job( prototype_job ), min_sleep: policy.worker_idle_min_sleep, max_sleep: policy.worker_idle_max_sleep )

    # type checks
    policy.pool_min_workers
    registry.workers

    # post-fork processing
    storage.reconnect_after_fork
    registry.reconnect_after_fork

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

    context = { worker: self }
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
    %Q[Worker(#{key})]
  end

  # the key is a constant string which uniquely identifies this worker
  # WARNING this would be invalidated if we forked or set this before forking
  def key
    @key ||= Hive::Key.new( name, Process.pid )
  end

  def mq
    @mq ||= Hive::Messager.new( storage, my_address: key )
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

  def resolve_job( job_factory )
    raise Hive::ConfigurationError if ! job_factory

    case
    when job_factory.respond_to?(:call)
      # A job factory can not be a proc, because a job itself is a proc; we would call it.
      # Once we've found a proc, we have the result.
      job_factory
    when job_factory.respond_to?(:new)
      context = { worker: self }
      resolve_job(job_factory.new(context))
    else
      case job_factory
      when String, Symbol
        resolve_job(Hive::Utilities::Resolver.resolve_class(job_factory.to_s))
      else
        raise Hive::ConfigurationError, "Unknown kind of job #{job_factory.inspect}"
      end
    end
  end

end # Hive::Worker
