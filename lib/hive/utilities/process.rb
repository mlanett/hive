module Hive::Utilities::Process
  
  def wait_impatiently( pid, deadline )
    status   = nil
    interval = 0.125
    begin # execute at least once to get status
      dummy, status = ::Process.wait2( pid, ::Process::WNOHANG )
      break if status
      log "Waiting for #{pid}", "Sleeping #{interval}" if false
      sleep(interval)
      interval *= 2 if interval < 1.0
    end while Time.now.to_i < deadline
    status
  end
  
  def wait_and_terminate( pid, options = {} )
    log "Monitoring job #{pid}" if false
    timeout = options[:timeout] || 1024
    signal  = options[:signal] || "HUP"
    
    status = wait_impatiently( pid, Time.now.to_i + timeout )
    return status if status
    
    log "Job #{pid} is overdue, killing"
    
    ::Process.kill( signal, pid )
    status = wait_impatiently( pid, Time.now.to_i + 1 )
    return status if status
    
    ::Process.kill( "TERM", pid ) if ! status
    dummy, status = ::Process.wait2( pid, ::Process::WNOHANG )
    status
  end
  
end # Hive::Utilities::Process
