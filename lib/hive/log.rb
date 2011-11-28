module Hive::Log
  
  def log( *args )
    log_io.print(log_message(*args))
    log_io.flush
  end

  def log_message( *args )
    message = [
      #(Time.now.strftime "%Y%m%d%H%M%S"),
      Time.now.to_i,
      " [",
      Process.pid,
      (Thread.current[:name] || Thread.current.object_id unless Thread.current == Thread.main),
      "] ",
      args.join(", "),
      "\n"
    ].compact.join
  end

  def log_io
    @log_io ||= STDOUT
  end

end # Hive::Log
