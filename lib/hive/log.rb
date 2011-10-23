module Hive::Log
  
  def log( *stuffs )
    message = [
      #(Time.now.strftime '%Y%m%d%H%M%S'),
      Time.now.to_i,
      " [",
      Process.pid,
      (Thread.current[:name] || Thread.current.object_id unless Thread.current == Thread.main),
      "] ",
      stuffs.join(", "),
      "\n"
    ].compact.join
    STDOUT.print(message)
    STDOUT.flush
  end
  
end # Hive::Log
