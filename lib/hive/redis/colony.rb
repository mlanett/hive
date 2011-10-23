class Hive::Redis::Colony
  
  include Hive::Log
  
  attr :running
  attr :pids
  
  def initialize( options = {} )
    @running = 0
    @pids    = {}
  end
  
  def launch( options = {}, &callable_block )
    callable = options[:callable] || callable_block
    
    collect while running >= 4
    pid = fork do
      callable.call
    end
    @running += 1
    log "LaunchedWorker #{pid}; Total Running #{running}"
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
  
end # Hive::Redis::Colony
