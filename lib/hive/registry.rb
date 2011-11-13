# -*- encoding: utf-8 -*-

=begin

  A registry knows how to lookup up and register workers.

=end

class Hive::Registry

  class Entry < Struct.new :pid, :key
  end

  attr :storage

  def initialize( storage )
    @storage = storage
  end

  def register( worker )
  end

  def unregister( worker )
  end

  def workers
    []
  end

  def live_workers( &block )
    workers.each(&block)
  end

  def with_registration( worker, &block )
    register(worker)
    begin
      yield
    ensure
      unregister(worker)
    end
  end

end # Hive::Registry
