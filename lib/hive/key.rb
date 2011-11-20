# -*- encoding: utf-8 -*-

=begin

  A key uniquely identifies a worker.

=end

class Hive::Key < Struct.new :name, :pid, :host

  attr :name
  attr :pid
  attr :host

  def initialize( name, pid, host = local_host )
    @name = name
    @pid  = pid
    @host = host
  end

  # e.g. processor-1234@foo.example.com
  def to_s
    "%s-%i@%s" % [ name, pid, host ]
  end

  def self.parse(key_string)
    key_string =~ /^(.*)-([0-9]+)@([^@]+)$/ or raise "Malformed Key (#{key_string})"
    new( $1, $2, $3 )
  end

  # ----------------------------------------------------------------------------
  # Utilities
  # ----------------------------------------------------------------------------

  # @returns something like foo.example.com
  def local_host
    @local_host ||= `hostname`.chomp.strip
  end

end
