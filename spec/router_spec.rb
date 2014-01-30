require 'spec_helper'

describe Superbolt::Router do
  let(:router) { Superbolt::Router.new(message, logger) }

  class MessageHandler
  end

  before do
    Superbolt::Router.routes = {
      'handler' => 'MessageHandler'
    }
  end

  let(:handler) { double('handler') }
  let(:logger) { Logger.new('/dev/null') }

  context 'when event maps to a known route' do
    let(:message) {
      {
        'event' => 'handler',
        'arguments' => {
          'yes' => 'we can'
        }
      }
    }

    it "performs the event handler" do
      MessageHandler.should_receive(:new).with({yes: 'we can'}, logger).and_return(handler)
      handler.should_receive(:perform)

      router.perform
    end
  end

  context 'when event is unknown' do
    let(:message) {
      {
        'event' => 'no_one_home',
        'arguments' => {
          'ah' => 'maybe not then'
        }
      }
    }

    it "logs a warning" do
      logger.should_receive(:warn).with("No Superbolt route for event: 'no_one_home'")

      router.perform
    end
  end
end