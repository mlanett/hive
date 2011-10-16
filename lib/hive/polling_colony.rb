class Hive::PollingColony
  
  include Hive::Log
  include Hive::Common
  
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
    
    collect while running >= 4
    pid = fork do
      log "Monitor started."
      
      real_pid = fork do
        callable.call
      end
      
      log "Monitor watching #{real_pid}"
      wait_and_terminate( real_pid, timeout )
      log "Monitor and worker complete."
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
