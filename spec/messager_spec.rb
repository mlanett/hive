# -*- encoding: utf-8 -*-

require "helper"

describe Hive::Messager, :redis => true do

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

  describe "implementation" do
    it "can encapsulate various messages" do
      storage  = Hive::Mocks::Storage.new
      it       = Hive::Messager.new( storage, my_address: @a )
      blob, id = it.encapsulate( "This is the message", at: 1234567890, from: "me@example" )
      # e.g. "{\"at\":1234567890,\"from\":\"me@example\",\"body\":\"This is the message\",\"id\":\"8ad1e3a0a27d88258df6c9646f6e0d0d\"}"
      blob.should match(/This is the message/)
      blob.should match(/me@example/)
    end
    it "can decapsulate a message" do
      storage       = Hive::Mocks::Storage.new
      a             = Hive::Messager.new( storage, my_address: @a )
      blob          = "{\"at\":1234567890,\"from\":\"me@example\",\"body\":\"This is the message\",\"id\":\"8ad1e3a0a27d88258df6c9646f6e0d0d\"}"
      body, headers = a.decapsulate(blob)
      body.should match(/^This is the message$/)
      headers.should eq({ "at" => 1234567890, "from" => "me@example", "id" => "8ad1e3a0a27d88258df6c9646f6e0d0d" })
    end
  end if false

  describe "the message id" do
  it "bases the message id on the source, content and timestamp" do
    storage = Hive::Mocks::Storage.new
    a       = Hive::Messager.new( storage, my_address: @a, to_address: @b )
    b       = Hive::Messager.new( storage, my_address: @b, to_address: @a )
    now     = 1234567890

    id1     = a.send "Hello", at: now
    id2     = a.send "Hello", at: now
    id1.should eq(id2)

    id3     = a.send "Hello", at: now+1
    id3.should_not eq(id1)

    id4     = a.send "Goodbye", at: now
    id4.should_not eq(id1)

    id5     = b.send "Hello", at: now
    id5.should_not eq(id1)
  end
  end

  it "can send and receive messages" do
    storage = Hive::Mocks::Storage.new

    a = Hive::Messager.new( storage, my_address: @a )
    a.send "Hello", to: @b

    b = Hive::Messager.new( storage, my_address: @b )
    callback = double("callback")
    callback.should_receive(:call).with("Hello",anything)

    b.receive() { |*args| callback.call(*args) }
  end

  it "can expect responses" do
    storage = Hive::Mocks::Storage.new

    a = Hive::Messager.new( storage, my_address: @a )
    id = a.send "Hello", to: @b

    a.expect(id) {}

    b = Hive::Messager.new( storage, my_address: @b )
    b.receive do |headers, body|
      b.send "Ok", to: @a
    end
  end

  it "can send a message between processes" do
    storage = Hive::Redis::Storage.new
  end

end
