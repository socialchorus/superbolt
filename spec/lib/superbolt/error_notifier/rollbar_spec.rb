require 'rails_helper'

describe Superbolt::ErrorNotifier::Rollbar do
  subject(:notifier) { described_class.new(Logger.new(out)) }
  let(:out) { StringIO.new('') }

  let(:error) { RuntimeError.new('ouch!')  }
  let(:message) { { the_superbolt: 'message' } }

  context 'when the app has Rollbar installed' do
    before do
      stub_const("::Rollbar", double(:Rollbar, error: nil))
    end

    it 'logs an error to Rollbar when there was one' do
      expect(Rollbar).to receive(:error).with(error, message)

      notifier.error!(error, message)
    end

    it 'can live without the message' do
      expect(Rollbar).to receive(:error).with(error, nil)

      notifier.error!(error)
    end
  end

  context 'when Rollbar is not there' do
    it 'will log a warning' do
      notifier.error!(error, message)

      expect(out.string).to include("Rollbar is not available or is not configured!")
    end
  end
end

