class Hive::SimpleColony
  
  include Hive::Log
  
  attr :running
  def initialize
    @running = 0
  end
  
  def launch( callable = nil, &callable_block )
    raise if callable && callable_block
    callable ||= callable_block
    
    land while running >= 4
    pid = fork do
      log "Launched"
      callable.call
      log "Exiting"
    end
    @running += 1
    log "Launched #{pid}; Total Running #{running}"
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
