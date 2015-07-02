require 'rails_helper'

describe Superbolt::ErrorNotifier::None do
  subject(:notifier) { described_class.new(double(:Logger)) }

  let(:error) { RuntimeError.new('ouch!')  }
  let(:message) { { the_superbolt: 'message' } }

  it 'does not fail' do
    notifier.error!(error)
    notifier.error!(error, message)
  end
end

