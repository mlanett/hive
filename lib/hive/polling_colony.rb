class Hive::PollingColony
  
  include Hive::Log
  
  attr :name
  attr :running
  attr :pids
  
  def initialize( options = {} )
    @name    = options[:name] || (begin @@cid ||= 0; @@cid += 1; end)
    @running = 0
    @pids    = {}
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
  
  include Log
  
  class Pid < Struct.new :pid, :start_time, :deadline, :window, :next_check, :last_status
    def to_s
      return [
        "Pid(",
        pid,
        Time.now - start_time,
        last_status
        ")"
      ].compact.join(",")
    end
  end
  
end # Hive::PollingColony
