require "hive"

c = Hive::PollingColony.new

p = lambda do
  t = rand(10)
  print "#{Process.pid} Hello, world!\n"
  sleep(t)
  print "#{Process.pid} Slept #{t} seconds.\n"
end

1000.times do
  c.launch( callable: p, timeout: 7 )
end

c.collect_all
