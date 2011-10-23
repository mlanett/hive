start, time
stop,  time
start, time
stop,  time
start, time
stop,  time

def generate
  now = Time.now.to_i
  10.times do
    puts -now
    now += rand(7)
    puts now
    now += rand(3)
  end
end

times = [-1318798764,1318798766,-1318798768,1318798768,-1318798768,1318798772,-1318798773,1318798776,-1318798777,1318798781,-1318798781,1318798781,-1318798783,1318798784,-1318798786,1318798792,-1318798793,1318798796,-1318798796,1318798800]

def analyze( start, times )
  whats = []
  whens = []
  last  = nil
  ( times + [Time.now.to_i] ).each do |time|
    if time < 0 then
      if last && whats[last] == :start then
        whats << :stop
        whens << -time
      end
      whats << :start
      whens << -time
    else
      if last && whats[last] == :stop then
        whats << :start
        whens << time
      end
      whats << :stop
      whens << time
    end
    last = (last || -1) + 1
  end
  [ whats, whens ]
end

analyze(times)
