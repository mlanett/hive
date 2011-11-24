# -*- encoding: utf-8 -*-

require "digest/md5"
require "json"

=begin

  Messager is used to send messages between processes, and receive responses.
  Messager messages are asynchronous and not ordered.

=end

class Hive::Messager

  attr :storage
  attr :my_address
  attr :to_address
  attr :queue_name
  attr :callbacks

  # @param options[:to_address] is optional
  # @param options[:my_address] is required
  def initialize( storage, options = {} )
    @callbacks  = {}
    @storage    = storage
    @to_address = options[:to_address]
    @my_address = options[:my_address] or raise "must specify my address"
    # type checking
    storage.get("test")
  end

  # write to another queue
  # @param options[:to] is required if :to_address was not given
  # @returns an id
  def send( body, options = {} )
    to        = to_address || options[:to] or raise "must specify to address"
    now       = options[:at] || Time.now
    blob, id  = encapsulate body, at: now

    storage.queue_add( queue_name(to), blob, now.to_i )
    id
  end

  # register a handler for a given id
  # the handler is removed when it is called
  def expect( id, &block )
    callbacks[id] = block
    self
  end

  # read from my queue
  # @param block takes (respond_to_address, body)
  def receive( options = {}, &block )
    now  = Time.now.to_i
    blob = storage.queue_pop( queue_name, now )
    if blob then
      body, headers = decapsulate( blob )
      id = headers["id"]
      if callback = callbacks[id] then
        callbacks.delete(id)
        callback.call( body, headers )
      else
        block.call( body, headers )
      end
    end
    self
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  # @param headers[:at] is optional; defaults to Time.now
  # @param headers[:from] is optional; defaults to my_address
  # @returns a json representation of the message, and the id
  def encapsulate( body, headers = {} )
    message           = Hash[ headers.map { |k,v| [ k.to_s, v ] } ] # stringify keys
    timestamp         = message["at"] || Time.now.to_f
    id                = digest([ my_address, body, timestamp ].join)
    message["at"]   ||= timestamp
    message["body"]   = body
    message["from"] ||= my_address
    message["id"]     = id
    [ message.to_json, id ]
  end

  def decapsulate( blob )
    message = JSON.parse(blob)
    body    = message.delete("body")
    [ body, message ]
  end

  def queue_name( other_address = nil )
    if other_address then
      "messages:#{other_address}"
    else
      @queue_name ||= "messages:#{my_address}"
    end
  end

  def digest( s )
    Digest::MD5.hexdigest(s)
  end

end
