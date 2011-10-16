require "hive"

C = Hive::SimpleColony

c = C.new

p = lambda do
  puts "#{Process.pid} Hello, world!"
  sleep rand(10)
  puts "#{Process.pid} Goodbye cruel world!"
end

10.times do
  c.launch(p)
end

c.collect_all
