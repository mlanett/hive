# -*- encoding: utf-8 -*-

module Hive::Utilities::Process
  
  def wait_until_deadline( pid, deadline )
    status   = nil
    interval = 0.125
    begin # execute at least once to get status
      dummy, status = wait2_now(pid)
      break if status
      #log "Waiting for #{pid}", "Sleeping #{interval}" if false
      sleep(interval)
      interval *= 2 if interval < 1.0
    end while Time.now.to_f < deadline
    status
  end


  def wait_and_terminate( pid, options = {} )
    #log "Monitoring job #{pid}"
    timeout = options[:timeout] || 1024
    signal  = options[:signal] || "HUP"
    
    status = wait_until_deadline( pid, Time.now.to_f + timeout )
    return status if status
    
    #log "Job #{pid} is overdue, killing"
    
    ::Process.kill( signal, pid )
    status = wait_until_deadline( pid, Time.now.to_f + 1 )
    return status if status
    
    ::Process.kill( "TERM", pid ) if ! status
    dummy, status = wait2_now(pid)
    status
  end


  def fork_and_detach( options = {}, &action)
    # Fork twice. First child doesn't matter. The second is our favorite.
    pid1 = fork do
      ::Process.setsid
      exit if fork
      redirect_stdio( options[:stdout] )
      action.call
    end

    # We must call waitpid on the first child to keep it from turning into a zombie
    ::Process.waitpid(pid1)
  end


  def wait2_now( pid )
    ::Process.wait2( pid, ::Process::WNOHANG )
  rescue Errno::ECHILD # No child processes
    return [ nil, 0 ]
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
    !! ::Process.kill( 0, pid )
  rescue Errno::ESRCH
    false
  end

  extend Hive::Utilities::Process

end # Hive::Utilities::Process
