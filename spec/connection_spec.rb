require 'spec_helper'

describe Superbolt::Adapter::Bunny do
  let(:connection) { Superbolt::Adapter::Bunny.new }
  let(:exchange_name) { connection.exchange_name }

  it "has an underlying open connection via Bunny" do
    connection.socket.should be_a Bunny::Session
    connection.socket.should be_open
    connection.should be_open
  end

  it "has a channel" do
    connection.channel.should be_a Bunny::Channel
  end

  it "delegates queue creation to the channel" do
    queue = connection.queue('changelica')
    queue.should be_a Bunny::Queue
    connection.queues.keys.should include('changelica')
  end

  it 'has a fanout exchange' do
    connection.exchange.type.should be(:fanout)
    connection.channel.find_exchange(exchange_name).should be_a(Bunny::Exchange)
    connection.channel.find_exchange(exchange_name + '.quit').should be_a(Bunny::Exchange)
    connection.channel.find_exchange(exchange_name + '.error').should be_a(Bunny::Exchange)
  end
end
