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
    
    collect while running >= 4
    
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
  
  def check( pid )
    dummy, status = Process.wait2( pid, Process::WNOHANG )
    status
  end
  
  def collect()
    # go through all pids
    pids = []
    @workers.each do |pid, worker|
      status = check( pid )
      pids << pid if status
    end
    pids.each do |pid|
      @workers.delete(pid)
      @running -= 1
      log "Collected #{pid}; Total Running #{running}"
    end
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
