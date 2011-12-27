module Collective::Log
  
  def log( *args )
    logger.print(format_for_logging(*args))
    logger.flush
  end

  def format_for_logging( *args )
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

  def logger
    @logger ||= STDOUT
  end

  def logger=( other )
    @logger = other
  end

end # Collective::Log
