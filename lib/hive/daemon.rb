require "erb"
require "daemon_spawn"
require "yaml"
require "hive"

class Hive::Daemon < DaemonSpawn::Base
  
  def self.run!( name )
    env  = ENV["ENV"] ||= ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
    dir  = "/tmp/#{name}_#{env}"
    Dir.mkdir(dir) if ! Dir.exists?(dir)
    sync = ( env == "development" )
    spawn!(
      working_dir: dir,
      log_file:    "#{dir}/#{env}.log",
      pid_file:    "#{dir}/#{env}.pid",
      sync_log:    sync
    )
  end
  
  def start( arguments )
    trap("TERM") { stop } # async stop
    
    file = arguments[0]
    conf = YAML::load( ERB.new( IO.read( file ) ).result )
    defs = conf.delete("defaults")
    conf = Hash[ conf.map { |k,v| [ k, defs.merge( v || {} ) ] } ]
    
    pools = conf.map do |name,options|
      if ! pclass = options.delete("class") then
        log "Can not use pool #{name}"
        next
      end
      pool = Hive::Pool.new( pclass, options )
    end
    
    i = Hive::Idler.new do
      pools.each { |pool| pool.synchronize }
      false
    end
    
    @ok = true
    while @ok do
      i.call
    end
    
    log "Done"
  end
  
  def stop
    log "Stopping"
    @ok = false
  end
  
  def log( *arguments )
    string = arguments.join(" ")
    STDOUT.printf "[#{Process.pid}] #{string}\n"
  end
  
end # Hive::Daemon
