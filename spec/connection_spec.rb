require 'spec_helper'

describe Superbolt::Connection do
  let(:connection) { Superbolt::Connection.new }

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
end
