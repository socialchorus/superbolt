require 'rails_helper'
require 'stringio'

describe Superbolt::ErrorNotifier::Airbrake do
  subject(:notifier) { described_class.new(logger) }

  let(:logger) { Logger.new(out) }
  let(:out) { StringIO.new('') }

  let(:error) { RuntimeError.new('ouch!')  }
  let(:message) { { the_superbolt: 'message' } }

  context 'when the app has Airbrake installed' do
    before do
      stub_const("::Airbrake", double(:Airbrake, notify_or_ignore: nil))
    end

    it 'logs an error to Airbrake when there was one' do
      expect(Airbrake).to receive(:notify_or_ignore).with(error, parameters: message)
      notifier.error!(error, message)
    end

    it 'can live without the message' do
      expect(Airbrake).to receive(:notify_or_ignore).with(error, parameters: nil)
      notifier.error!(error)
    end
  end

  context 'when Airbrake is not there' do
    it 'will not break' do
      expect(defined? Airbrake).to be_nil
      notifier.error!(error, message)
      # no errors
    end

    it 'will log a warning' do
      notifier.error!(error, message)
      expect(out.string).to include('Airbrake is not available or is not configured!')
    end
  end
end
