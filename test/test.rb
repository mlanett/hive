require "hive"

c = Hive::ThreadedColony.new

p = lambda do
  t = rand(10)
  print "#{Process.pid} Hello, world!\n"
  sleep(t)
  print "#{Process.pid} Slept #{t} seconds.\n"
end

10.times do
  c.launch( :callable => p, :timeout => 2 )
end

c.collect_all
