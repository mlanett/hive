# -*- encoding: utf-8 -*-

class Hive::LifecycleObserver < Hive::Utilities::ObserverBase

  attr :key
  attr :registry

  def initialize( key, registry )
    @key      = key
    @registry = registry
  end

  def worker_started
    registry.register( key )
  end

  def worker_heartbeat( upcount = 0 )
    registry.update( key )
  end

  def worker_stopped
    registry.unregister( key )
  end

end # Hive::LifecycleObserver
