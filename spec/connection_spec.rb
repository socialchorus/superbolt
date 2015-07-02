require 'spec_helper'

describe Superbolt::Adapter::Bunny do
  let(:connection) { Superbolt::Adapter::Bunny.new }

  it "has an underlying open connection via Bunny" do
    expect(connection.socket).to be_a Bunny::Session
    expect(connection.socket).to be_open
    expect(connection).to be_open
  end

  it "has a channel" do
    expect(connection.channel).to be_a Bunny::Channel
  end

  it "delegates queue creation to the channel" do
    queue = connection.queue('changelica')
    queue.should be_a Bunny::Queue
    expect(connection.queues.keys).to include('changelica')
  end
end
