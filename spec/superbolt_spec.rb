require 'spec_helper'

describe Superbolt, 'the facade' do
  before do
    Superbolt.instance_eval do
      @config = nil
    end
  end

  describe 'total configuration' do
    before do
      Superbolt.app_name = 'bossanova'
      Superbolt.env = 'production'
      Superbolt.error_notifier = :airbrake
      Superbolt.config = {
        connection_key: 'SOME_RABBITMQ_URL'
      }
    end

    after { Superbolt.error_notifier = nil }

    it "should retain the configuration information" do
      expect(Superbolt.config.app_name).to eq('bossanova')
      expect(Superbolt.config.env).to eq('production')
      expect(Superbolt.config.env_connection_key).to eq('SOME_RABBITMQ_URL')
      expect(Superbolt.config.error_notifier).to eq(:airbrake)
    end
  end

  describe '.config' do
    it "has a default" do
      expect(Superbolt.config).to eq(Superbolt::Config.new({}))
    end

    it "can be customized" do
      Superbolt.config = {
        connection_key: 'SOME_RABBITMQ_URL'
      }

      expect(Superbolt.config.env_connection_key).to eq('SOME_RABBITMQ_URL')
    end
  end

  describe '.queue' do
    it "creates a queue with the default config" do
      queue = double('queue')
      Superbolt::Queue.should_receive(:new)
        .with('queue_name', Superbolt.config)
        .and_return(queue)
      expect(Superbolt.queue('queue_name')).to eq(queue)
    end
  end

  describe '.message' do
    it "sends messages via the messenger system" do
      queue = Superbolt.queue('activator_test')
      queue.clear
      Superbolt.env = 'test'
      Superbolt.app_name = 'bossanova'

      Superbolt.message
        .to('activator')
        .re('update')
        .send!({class: 'Advocate'})

      expect(queue.pop).to eq({
        'origin' => 'bossanova',
        'event' => 'update',
        'arguments' => {
          'class' => 'Advocate'
        }
      })
    end
  end
end
