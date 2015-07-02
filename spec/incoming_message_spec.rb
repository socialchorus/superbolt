require 'spec_helper'

describe Superbolt::IncomingMessage do
  let(:message){ Superbolt::IncomingMessage.new(delivery_info, payload, channel) }
  let(:payload){ { some: "message" }.to_json }
  let(:delivery_info) { double("info", delivery_tag: "tag") }
  let(:channel) { double("channel") }

  describe '#parse' do
    context 'payload is not json' do
      let(:payload) { 'foo' }

      it 'just returns the payload' do
        expect(message.parse).to eq(payload)
      end
    end

    context 'payload is json' do
      it "parses it to a hash" do
        expect(message.parse).to eq({'some' => 'message'})
      end
    end
  end

  describe '#reject' do
    it "calls reject on the channel with the appropritate data and options" do
      expect(channel).to receive(:reject).with('tag', true)

      message.reject
    end

    it "can reject without requeuing" do
      expect(channel).to receive(:reject).with('tag', false)

      message.reject(false)
    end
  end

  describe "#ack" do
    it "calls acknowledge on the channel" do
      expect(channel).to receive(:acknowledge).with('tag')

      message.ack
    end
  end
end