# This approach doesn't work either; @see http://fossplanet.com/f14/%5Bruby-core-23572%5D-%5Bbug-1525%5D-deadlock-ruby-1-9s-vm-caused-conditionvariable-wait-fork-31935/

class Hive::ThreadedColony
  
  include Hive::Log
  include Hive::Common
  
  attr :workers
  attr :threads
  
  def initialize
    @workers = 0
    @threads = {}
    @nexttid = 1
  end
  
  def collect_all
    while workers > 0 do
      if e = threads.first
        if t = e.last then
          log "Joining #{t[:name]}"
          t.join
        end
      end
    end
  end
  
  def launch( options = {}, &callable_block )
    raise if options[:callable] && callable_block
    callable = options[:callable] || callable_block
    
    thread = Thread.new(options) do |options|
      Thread.current[:name] = newtid.to_s
      log "Thread Starting"
      
      pid = fork do
        Thread.current[:name] = nil
        log "Worker Starting"
        callable.call
        log "Worker Exiting"
      end # fork
      
      Thread.current[:name] = [ newtid, pid ].join("-")
      wait_and_terminate( pid, options )
      
      # Safe even if out of order
      Thread.exclusive { @threads.delete(Thread.current.object_id); @workers -= 1 }
        
      log "Thread Complete"
    end # thread
    
    # Safe even if out of order
    Thread.exclusive { @threads[thread.object_id] = thread; @workers += 1 }
    
    log "Forked Worker #{thread[:name]}"
    return thread
  end # launch
  
  def newtid
    tid = @nexttid
    Thread.exclusive { @nexttid += 1 }
    tid
  end
  
end # Hive::ThreadedColony
