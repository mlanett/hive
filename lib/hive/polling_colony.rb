class Hive::PollingColony
  
  include Hive::Log
  include Hive::Common
  
  attr :running
  attr :workers
  
  def initialize( options = {} )
    @running = 0
    @workers = {}
  end
  
  def launch( options = {}, &callable_block )
    callable = options[:callable] || callable_block
    timeout  = options[:timeout] || 1024
    
    collect while running >= 40
    
    pid = fork do
      # this is the monitor
      
      real_pid = fork do
        # this is the real job
        callable.call
      end
      
      result = wait_and_terminate( real_pid, timeout: timeout )
      log "Job complete, result: #{result}."
    end
    
    worker = launched( pid, timeout )
    log "Launched #{worker}; Total Running #{running}"
    pid
  end
  
  def launched( pid, timeout, start_time = Time.now.to_i )
    @running += 1
    @workers[pid] = Worker.new( pid, start_time, start_time + timeout, 0.125, start_time + 0.125 )
  end
  
  def check( worker )
  end
  
  def collect()
    # go through all pids
    pids    = []
    now     = Time.now.to_i
    soonest = now + 1
    @workers.each do |pid, worker|
      next if now < worker.next_check
      
      # log "Checking #{worker.pid}"
      dummy, status = Process.wait2( worker.pid, Process::WNOHANG )
      pids << worker.pid and next if status
      
      worker.window *= 2 if worker.window < 1.0
      worker.next_check = now + worker.window
      soonest = worker.next_check if worker.next_check < soonest
    end
    pids.each do |pid|
      @workers.delete(pid)
      @running -= 1
      log "Collected #{pid}; Total Running #{running}"
    end
    sleep( soonest - now )
  end
  
  def collect_all
    collect while running > 0
  end
  
  class Worker < Struct.new :pid, :start_time, :deadline, :window, :next_check
    def to_s
      return [
        "Worker(", [
          pid,
          Time.now.to_i - start_time
        ].compact.join(","),
        ")"
      ].compact.join
    end
  end
  
end # Hive::PollingColony
