# -*- encoding: utf-8 -*-

require "optparse"
require "ruby-debug"

=begin

Evaluate a ruby configuration file in the context of a Hive Configuration instance.
Offers a DSL to build the jobs as well as setting before/after-fork hooks.

Hive configuration:

env()
set_env(ENV)
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
      opts.on( "-e", "--env ENV",     "Set environment (env).")       { |e| us.set_env(e) }
      opts.on( "-h", "--help",        "Display this usage summary." ) { puts opts; exit }
      opts.on( "-n", "--name NAME",   "Set daemon's name.")           { |n| us.set_name(n) }
      opts.on( "-p", "--path PATH",   "Add to load path.")            { |d| us.add_path(d) }
      opts.on( "-r", "--require LIB", "Require a library.")           { |l| us.require_lib(l) }
      opts.on( "-s", "--script DSL",  "Include DSL script.")          { |s| us.load_script(s) }
      opts.on( "-v", "--verbose",     "Print stuff out.")             { |s| us.verbose += 1 }
      opts.on( "--dry-run",           "Don't launch the daemon.")     { us.dry_run = true }
    end.parse!(argv)

    while argv.any? && File.exists?(argv.first) do
      us.load_file( argv.shift )
    end

    us.args = argv
    us.finalize
  end

  include Hive::Log

  attr :env
  attr :root
  attr :name, true
  attr :verbose, true
  attr :dry_run, true
  attr :args, true
  attr :before_forks
  attr :after_forks

  attr :defaults
  attr :jobs

  def initialize( filename = nil )
    @verbose  = 0
    @dry_run  = false
    @defaults = {}
    @jobs     = {}
    load_file(filename) if filename
  end

  def load_script(string)
    log "Loading #{string}" if verbose >= 2
    instance_eval(string)
  end

  def load_file(filename)
    log "Loading #{filename}" if verbose >= 1
    instance_eval(File.read(filename),filename)
    if ! name then
      n = File.basename(filename).sub(/\.[^.]*$/,'')
      @name = n if n.size > 0 
    end
  end

  def finalize()
    if ! env then
      @env = ( ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "test" )
      log "Defaulting env to #{env}" if verbose >= 1
    end
    if ! name then
      @name = "hive"
      log "Defaulting name to #{name}" if verbose >= 1
    end
    if ! @root then
      chdir(default_root)
    end
    log inspect if verbose >= 2
    freeze
    self
  end

  def options_for_daemon_spawn
    mkdirp root, "#{root}/log", "#{root}/tmp", "#{root}/tmp/pids" if ! dry_run
    return {
      working_dir: root,
      log_file:    "#{root}/log/#{name}_#{env}.log",
      pid_file:    "#{root}/tmp/pids/#{name}_#{env}.pid",
      sync_log:    local?
    }
  end

  def args_for_daemon_spawn
    args + [self]
  end

  # ----------------------------------------------------------------------------
  # DSL
  # ----------------------------------------------------------------------------

  def set_env(env)
    @env = env
  end

  def set_name(name)
    @name = name
  end

  # takes effect immediately
  def chdir(path)
    if ! @root then
      p = File.expand_path(path)
      mkdirp(p) if ! dry_run
      Dir.chdir(p)
      log "Changed working directory (root) to #{p}" if verbose >= 1
      @root = p
    else
      log "Warning: working directory already set to #{root}; not changing to #{path}"
    end
  end

  # takes effect immediately
  def add_path(path)
    p = File.expand_path(path)
    log "Added #{p} to load path" if verbose >= 2
    $:.push(p) unless $:.member?(p)
  end

  # convenience for -r on the command line
  def require_lib(r)
    require(r)
    log "Required #{r}" if verbose >= 2
  end

  def set_default(key,value)
    # values which are arrays get merged, but nil will overwrite
    case value
    when Array
      @defaults[key] = (@defaults[key] || []) + value
    else
      @defaults[key] = value
    end
  end

  def set_defaults(options)
    options.each { |k,v| set_default(k,v) }
  end
  
  def add_pool(name,options)
    options = defaults.merge(options)
    jobs[name] = options
    log "Added pool for #{name}" if verbose == 1
    log "Added pool for #{name} with #{options}" if verbose >= 2
  end

  def before_fork(&block)
    @before_forks ||= []
    @before_forks << block
  end

  def after_fork(&block)
    @after_forks ||= []
    @after_forks << block
  end

  # ----------------------------------------------------------------------------
  private
  # ----------------------------------------------------------------------------

  def local?
    %w(development test).member?(env)
  end

  def default_root
    local? ? "." : "/tmp/#{name}"
  end

  def mkdirp(*ps)
    ps.each { |p| Dir.mkdir(p) if ! Dir.exists?(p) }
  end

end
