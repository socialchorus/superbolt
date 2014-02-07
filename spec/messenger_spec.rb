require 'spec_helper'

describe Superbolt::Messenger do
  let(:env) { 'test' }
  let(:name) { 'my_friend_app' }
  let(:queue) { Superbolt::Queue.new("#{name}_#{env}") }

  before do
    queue.clear
    Superbolt.app_name = nil
    Superbolt.env = env
  end

  let(:messenger) { Superbolt::Messenger.new }

  describe 'queue generation' do
    it "can be instantiated with a queue destination" do
      m = Superbolt::Messenger.new(to: name)
      m.name.should == name
      m.queue.name.should == "#{name}_#{env}"
    end

    it "destination queue can be set via #from" do
      messenger.to('activator')
      messenger.queue.name.should == "activator_#{env}"
    end

    it "raises an error if the name is nil" do
      expect {
        messenger.queue
      }.to raise_error
    end
  end

  describe 'underlying message' do
    let(:message) { messenger.message }

    context 'writing' do
      it "starts its life with no interesting values" do
        message[:origin].should == nil
        message[:event].should == 'default'
        message[:arguments].should == {}
      end

      it "calls to #from, set the origin on the message" do
        messenger.from('linkticounter')
        message[:origin].should == 'linkticounter'
      end

      it "passes event data to the message" do
        messenger.re('zap')
        message[:event].should == 'zap'
      end

      it "passes data to the message" do
        messenger.data({foo: 'bar'})
        message[:arguments].should == {foo: 'bar'}
      end
    end

    context 'reading' do
      it '#to returns the name' do
        messenger.to('transducer')
        messenger.to.should == 'transducer'
      end

      it '#from returns the origin' do
        messenger.from('activator')
        messenger.from.should == 'activator'
      end

      it '#re returns the event' do
        messenger.re('save')
        messenger.re.should == 'save'
      end

      it '#data return the arguments' do
        messenger.data({foo: 'bar'})
        messenger.data.should == {foo: 'bar'}
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
      queue.pop.should == {
        'origin' => 'me',
        'event' => 'love',
        'arguments' => 'none'
      }
    end
  end
end
