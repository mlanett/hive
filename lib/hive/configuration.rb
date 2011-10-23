# -*- encoding: utf-8 -*-

=begin

Evaluate a ruby configuration file in the context of a Hive Configuration instance.
Offers a DSL to build the jobs as well as setting before/after-fork hooks.

Hive configuration:

env()
env=(ENV)
--env=ENV
Sets the environment.
Used in pid file and log file naming.
Defaults to RAILS_ENV || RACK_ENV || "test".

chdir(DIR)
--chdir=DIR
Changes the working directory. Creates it if necessary.
Takes effect immediately.
Can only be set once. Has no effect if specified more than once.
Defaults to /tmp/$NAME

name()
name=(NAME)
--name=NAME
Sets the name of the process.
Defaults to the base name of the configuration file.
Used in pid file and log file naming.

--path=PATH
add_path(PATH)
Adds a path to the Ruby load path.
Can be used multiple times.

--require=LIB
Requires a library or Ruby gem.
Can be used multiple times.

=end

class Hive::Configuration

  def self.parse( argv = ARGV )
    us = new

    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]* configuration_file_rb"
      opts.on( "-c", "--chdir DIR",   "Change working directory." )   { |d| us.chdir(d) }
      opts.on( "-e", "--env ENV",     "Set environment (env).")       { |e| us.env = e }
      opts.on( "-h", "--help",        "Display this usage summary." ) { puts opts; exit }
      opts.on( "-n", "--name NAME",   "Set daemon's name.")           { |n| us.name = n }
      opts.on( "-p", "--path PATH",   "Add to load path.")            { |d| us.add_path(d) }
      opts.on( "-r", "--require LIB", "Require a library.")           { |l| us.require_lib(l) }
      opts.on( "-s", "--script DSL",  "Include DSL script.")          { |s| us.load_dsl(s) }
    end.parse!

    argv.compact.each { |f| us.load_file(f) }

    us.finalize
  end

  include Hive::Log

  attr :env
  attr :root
  attr :name, true
  
  attr :defaults
  attr :jobs

  def initialize()
    @defaults = {}
    @jobs     = {}
  end

  def load_dsl(string)
    instance_eval(string)
  end

  def load_file(filename)
    instance_eval(File.read(filename),filename)
    if ! name then
      n = File.basename(filename).sub(/\.[^.]*$/,'')
      @name = n if n.size > 0 
    end
  end

  def finalize()
    if ! env then
      @env = ( ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "test" )
    end
    if ! name then
      @name = "hive"
    end
    if ! @root then
      chdir "/tmp/#{name}"
    end
    freeze
    self
  end
  
  # ----------------------------------------------------------------------------
  # DSL
  # ----------------------------------------------------------------------------

  def env=(e)
    if @env then
      log "Warning: changing environment from #{@env} to #{e}"
    end
    @env = e
  end
  
  # takes effect immediately
  def chdir(path)
    p = File.expand_path(path)
    Dir.mkdir(p) if ! Dir.exists?(p)
    Dir.chdir(p)
    @root = p
  end

  # takes effect immediately
  def add_path(path)
    p = File.expand_path(path)
    $:.push(p) unless $:.member?(p)
  end

  # convenience for -r on the command line
  def require_lib(r)
    require(r)
  end
  
  def set_defaults(options)
    @defaults.merge!(options)
  end
  
  def add_pool(name,options)
    options = defaults.merge(options)
    jobs[name] = options
  end

  def before_fork(&block)
  end

  def after_fork(&block)
  end

end
