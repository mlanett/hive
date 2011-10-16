class Hive::SimpleColony
  
  include Hive::Log
  
  attr :running
  def initialize
    @running = 0
  end
  
  def launch( options = {}, &callable_block )
    raise if options[:callable] && callable_block
    callable = options[:callable] || callable_block
    
    land while running >= 4
    pid = fork do
      log "Worker Starting"
      callable.call
      log "Worker Exiting"
    end
    @running += 1
    log "Forked Worker #{pid}; Total Running #{running}"
    pid
  end
  
  def land()
    pid = Process.wait
    @running -= 1
    log "Landed #{pid}; Total Running #{running}"
  end
  
  def collect_all
    land while running > 0
  end
  
end # Hive::SimpleColony
