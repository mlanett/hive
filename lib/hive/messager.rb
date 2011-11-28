# -*- encoding: utf-8 -*-

require "digest/md5"
require "json"

=begin

  Messager is used to send messages between processes, and receive responses.
  Messager messages are asynchronous and not ordered.

=end

class Hive::Messager

  attr :callbacks
  attr :storage
  attr :my_address
  attr :to_address

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
    to        = options[:to] || to_address or raise "must specify to address"
    from      = options[:from] || my_address or raise "must specify from address"
    now       = options[:at] || Time.now
    message   = Message.new( options.merge( to: to, from: my_address, at: now, body: body ) )
    blob      = message.to_json

    storage.queue_add( queue_name(to), blob, now.to_i )
    message.id
  end

  # register a handler for a given id
  # the handler is removed when it is called
  def expect( match, &callback )
    @callbacks[match] = callback
    self
  end

  # sends a new message to the original message source and with reply_to_id from the original message
  # @param options[:to] must be the original message
  # @e.g. reply "Ok", to: question
  def reply( body, options )
    original = options[:to] or raise "must reply to: message"
    send( body, to: original.from, reply_to_id: original.id )
  end

  # @param reply_block takes (body, headers)
  def expect_reply( src_id, &reply_block )
    raise
  end

  # read from my queue
  # check to see if there are any messages, and dispatch them
  def receive()
    now  = Time.now.to_i
    json = storage.queue_pop( queue_name, now )
    if json then
      message  = Message.parse(json)
      callback = find_callback( message )
      callback.call( message.body, message )
    end
  end

  # ----------------------------------------------------------------------------
  # Message contains the body and critical headers for Messager
  # ----------------------------------------------------------------------------

  class Message

    attr :to           # destination host
    attr :from         # source host
    attr :at           # timestamp of message generation
    attr :body         # JSON-compatible
    attr :id           # autogenerated if not supplied
    attr :reply_to_id  # optional

    def initialize( data )
      data         = ::Hive::Messager.symbolize(data)
      @to          = data[:to] or raise "must specify to address"
      @from        = data[:from] or raise "must specify from address"
      @at          = (data[:at] || Time.now).to_f
      @body        = data[:body]
      @id          = data[:id] || Digest::MD5.hexdigest([from,at,body].join)
      @reply_to_id = data[:reply_to_id]
    end

    def to_hash
      blob = { to: to, from: from, at: at, body: body, id: id }
      blob[:reply_to_id] = reply_to_id if reply_to_id
      blob
    end

    def to_json
      to_hash.to_json
    end

    def to_s
      to_json
    end

    def self.parse( json )
        new( JSON.parse(json) )
    end

  end # Message

  # ----------------------------------------------------------------------------
  # Utilities
  # ----------------------------------------------------------------------------

  def self.stringify(map)
    Hash[ map.map { |k,v| [ k.to_s, v ] } ]
  end

  def self.symbolize(map)
    Hash[ map.map { |k,v| [ k.to_sym, v ] } ]
  end

  # ----------------------------------------------------------------------------
  protected
  # ----------------------------------------------------------------------------

  def queue_name( other_address = nil )
    if other_address then
      "messages:#{other_address}"
    else
      @queue_name ||= "messages:#{my_address}"
    end
  end

  # ----------------------------------------------------------------------------
  # Match
  # ----------------------------------------------------------------------------

  class NoMatch < Exception
  end

  class Counter
    def match
      @value ||= 0
      @value += 1
    end
    def fail
      @value = nil
      raise NoMatch
    end
    def value
      raise NoMatch if !@value
      @value
    end
  end

  def find_callback( message )
    best_result = nil
    best_score = nil
    callbacks.each do |match,callback|
      begin
        counter = Counter.new
        compare_match( message, match, counter )
        if !best_score || counter.value > best_score then
          best_score  = counter.value
          best_result = callback
        end
      rescue NoMatch
        # next
      end
    end
    return best_result if best_result
    debugger
    raise NoMatch
  end

  def compare_match( message, match, counter )
    case match
    when String
      compare( message.body, match, counter )
    when Hash
      compare( message.to_hash, match, counter )
    end
  end

  def compare( item, match, counter )
    case match
    when Numeric
      return item.kind_of?(Numeric) && item == match ? counter.match : counter.fail
    when String
      return item.kind_of?(String) && item == match ? counter.match : counter.fail
    when Regexp
      return item.kind_of?(String) && item =~ match ? counter.match : counter.fail
    when Hash
      counter.fail if ! item.kind_of?(Hash)
      match.each do |k,v|
        counter.fail if ! item.has_key?(k)
        compare( item[k], match[k], counter )
      end
    else
      raise "Can not compare using #{match.inspect}"
    end
  end

end
