require 'spec_helper'

describe Superbolt::Adapter::Bunny do
  let(:connection) { Superbolt::Adapter::Bunny.new }
  let(:channel) { connection.new_channel }

  it "has an underlying open connection via Bunny" do
    connection.socket.should be_a Bunny::Session
    connection.socket.should be_open
    connection.should be_open
  end

  describe 'new_channel' do
    it "creates a channel" do
      connection.new_channel.should be_a Bunny::Channel
    end
  end

  it "delegates queue creation to the channel" do
    queue = channel.queue('changelica')
    queue.should be_a Bunny::Queue
    channel.queues.keys.should include('changelica')
  end
end
