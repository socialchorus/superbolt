require 'rails_helper'

describe Superbolt::Messenger do
  let(:env) { 'test' }
  let(:name) { 'my_friend_app' }
  let(:queue) { Superbolt::Queue.new("#{name}_#{env}") }

  before do
    queue.clear
    Superbolt.env = env
    Superbolt.app_name = nil
  end

  let(:messenger) { Superbolt::Messenger.new }

  describe 'queue generation' do
    it "can be instantiated with a queue destination" do
      m = Superbolt::Messenger.new(to: name)
      expect(m.name).to eq(name)
      expect(m.queue.name).to eq("#{name}_#{env}")
    end

    it "destination queue can be set via #from" do
      messenger.to('activator')
      expect(messenger.queue.name).to eq("activator_#{env}")
    end

    it "raises an error if the name is nil" do
      expect {
        messenger.queue
      }.to raise_error(RuntimeError)
    end
  end

  describe 'underlying message' do
    let(:message) { messenger.message }

    context 'writing' do
      it "starts its life with no interesting values" do
        expect(message[:origin]).to eq(nil)
        expect(message[:event]).to eq('default')
        expect(message[:arguments]).to eq({})
      end

      it "calls to #from, set the origin on the message" do
        messenger.from('linkticounter')
        expect(message[:origin]).to eq('linkticounter')
      end

      it "passes event data to the message" do
        messenger.re('zap')
        expect(message[:event]).to eq('zap')
      end
    end

    context 'reading' do
      it '#to returns the name' do
        messenger.to('transducer')
        expect(messenger.to).to eq('transducer')
      end

      it '#from returns the origin' do
        messenger.from('activator')
        expect(messenger.from).to eq('activator')
      end

      it '#re returns the event' do
        messenger.re('save')
        expect(messenger.re).to eq('save')
      end

      it '#data return the arguments' do
        messenger.data({foo: 'bar'})
        expect(messenger.data).to eq({foo: 'bar'})
      end
    end
  end

  describe 'send!' do
    before do
      messenger
        .to(name)
        .from('me')
        .re('love')
    end

    it "returns a hash that gets sent to the right queue" do
      messenger.send!('none')
      expect(queue.pop).to eq({
        'origin' => 'me',
        'event' => 'love',
        'arguments' => 'none'
      })
    end
  end
end
