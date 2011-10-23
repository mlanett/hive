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

  def fork_and_detach( options = {}, &action)
    fork do
      ::Process.setsid
      exit if fork
      redirect_stdio( options[:stdout] )
      action.call
    end
  end

  def redirect_stdio( stdout )
    STDIN.reopen "/dev/null"
    if stdout then
      mask = File.umask(0000)
      file = File.new( stdout, "a" ) # append or create, write only
      File.umask( mask )
      STDOUT.reopen( file )
    else
      STDOUT.reopen "/dev/null"
    end
    STDERR.reopen(STDOUT)
  end

  def alive?( pid )
    ::Process.kill( 0, pid )
  rescue Errno::ESRCH
    false
  end

end # Hive::Utilities::Process
