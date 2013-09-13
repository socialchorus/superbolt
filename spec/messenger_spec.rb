require 'spec_helper'

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

      describe '#retry_time' do
        before do
          Superbolt.config.options[:retry_time] = nil
        end

        context 'config contains retry_time' do
          it 'returns config value' do
            Superbolt.config.options[:retry_time] = 12
            messenger.retry_after.should == 12
          end
        end

        context 'config does not contain retry_time but we pass it in' do
          it 'returns passed in value' do
            messenger.retry_after(11)
            messenger.retry_after.should == 11
          end
        end

        context 'config does not contain retry_time and we dont pass it in' do
          it 'returns default value' do
            messenger.retry_after.should == 10
          end
        end
      end

      describe '#retry_time' do
        before do
          Superbolt.config.options[:timeout] = nil
        end

        context 'config contains retry_time' do
          it 'returns config value' do
            Superbolt.config.options[:timeout] = 120
            messenger.timeout_after.should == 120
          end
        end

        context 'config does not contain retry_time but we pass it in' do
          it 'returns passed in value' do
            messenger.timeout_after(90)
            messenger.timeout_after.should == 90
          end
        end

        context 'config does not contain retry_time and we dont pass it in' do
          it 'returns default value' do
            messenger.timeout_after.should == 60
          end
        end
      end
    end
  end

  describe 'send!' do
    before do
      Superbolt.config.options[:retry_time] = 0
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
