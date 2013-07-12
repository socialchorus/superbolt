require 'spec_helper'

describe Superbolt, 'the facade' do
  describe '.config' do
    before do
      Superbolt.instance_eval do
        @config = nil
      end
    end

    it "stores the default" do
      Superbolt.config.should == Superbolt::Config.new
    end

    it "can be customized" do
      Superbolt.config = {
        connection_key: 'SOME_RABBITMQ_URL'
      }

      Superbolt.config.env_connection_key.should == 'SOME_RABBITMQ_URL'
    end
  end
end
