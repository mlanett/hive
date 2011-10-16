class Hive::SimpleColony
  
  include Hive::Log
  include Hive::Common
  
  attr :running
  def initialize
    @running = 0
  end
  
  def launch( options = {}, &callable_block )
    raise if options[:callable] && callable_block
    callable = options[:callable] || callable_block
    timeout  = options[:timeout] || 1024
    
    collect while running >= 4
    pid = fork do
      # this is the monitor
      
      real_pid = fork do
        # this is the real job
        callable.call
      end
      
      result = wait_and_terminate( real_pid, :timeout => timeout )
      log "Job complete, result: #{result}."
    end
    @running += 1
    log "Forked Worker #{pid}; Total Running #{running}"
    pid
  end
  
  def collect()
    pid = Process.wait
    @running -= 1
    log "Collected #{pid}; Total Running #{running}"
  end
  
  def collect_all
    collect while running > 0
  end
  
end # Hive::SimpleColony
