# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Messager, redis: true do

  before do
    @a = "me@example.com"
    @b = "you@example.com"
  end

  it "can take to_address initially or per message" do
    storage = Hive::Mocks::Storage.new

    a = Hive::Messager.new( storage, my_address: @a )
    expect { a.send "Hello" }.to raise_exception
    expect { a.send "Hello", to: @b }.to_not raise_exception

    b = Hive::Messager.new( storage, my_address: @a, to_address: @b )
    expect { b.send "Hello" }.to_not raise_exception
  end

  it "the message id varies with the source, content and timestamp" do
    storage = Hive::Mocks::Storage.new
    a       = Hive::Messager.new( storage, my_address: @a, to_address: @b )
    b       = Hive::Messager.new( storage, my_address: @b, to_address: @a )
    now     = 1234567890

    id1     = a.send "Hello", at: now
    id3     = a.send "Hello", at: now+1
    id4     = a.send "Goodbye", at: now
    id5     = b.send "Hello", at: now

    id3.should_not eq(id1)
    id4.should_not eq(id1)
    id5.should_not eq(id1)
  end

  describe "sending and receiving messages" do

    it "can match against a string" do
      storage = Hive::Mocks::Storage.new
      a = Hive::Messager.new( storage, my_address: @a )
      b = Hive::Messager.new( storage, my_address: @b )
      b.expect("Hello") { |body,message| false }
      a.send "Hello", to: @b
      expect { b.receive }.to_not raise_exception
    end

    it "can match against a regexp" do
      storage = Hive::Mocks::Storage.new
      a = Hive::Messager.new( storage, my_address: @a )
      b = Hive::Messager.new( storage, my_address: @b )
      b.expect(/ello/) { |body,message| false }
      a.send "Hello", to: @b
      expect { b.receive }.to_not raise_exception
    end

    it "returns true if it got a message" do
      storage = Hive::Mocks::Storage.new
      a = Hive::Messager.new( storage, my_address: @a )
      b = Hive::Messager.new( storage, my_address: @b )
      b.expect(//) { |body,message| false }
      a.receive.should eq(false)
      a.send "Hello", to: @b
      b.receive.should eq(true)
      b.receive.should eq(false)
    end

    it "can send and receive messages" do
      storage = Hive::Mocks::Storage.new
      a = Hive::Messager.new( storage, my_address: @a )
      b = Hive::Messager.new( storage, my_address: @b )

      callback = double("callback")
      callback.should_receive(:call).with("Goodbye",anything)

      reply_to_id = nil

      b.expect("Hello") { |body,message|
        body.should eq("Hello")
        message.from.should eq(@a)
        reply_to_id = message.id
        b.reply( "Goodbye", to: message )
      }

      a.expect("Goodbye") { |body,message|
        body.should eq("Goodbye")
        message.from.should eq(@b)
        message.id.should_not be_nil
        message.reply_to_id.should eq(reply_to_id)
        callback.call(body,message)
      }

      a.send "Hello", to: @b
      b.receive
      a.receive
    end

  end

  describe "when working with multiple processes", redis: true do

    it "can send a message between processes" do
      storage = Hive::Redis::Storage.new(redis)
      me = Hive::Messager.new( storage, my_address: @a )

      ok = false
      me.expect("Goodbye") do |body,message|
        ok = true
      end

      Hive::Utilities::Process.fork_and_detach do
        redis.client.disconnect
        me = Hive::Messager.new( storage, my_address: @b )
        ok = false
        me.expect("Hello") do |body,message|
          me.reply "Goodbye", to: message
          ok = true
        end
        wait_until { me.receive; ok }
      end

      me.send "Hello", to: @b
      wait_until { me.receive }
      ok.should be_true
    end

  end

end
