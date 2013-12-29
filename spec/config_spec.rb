require 'spec_helper'

describe Superbolt::Config do
  let(:config) {
    Superbolt::Config.new(options)
  }

  let(:options) {
    {}
  }

  describe 'non connection configuration' do
    let(:options) {
      {
        app_name: 'my_great_app',
        env: 'staging'
      }
    }

    it "should make the app name available" do
      config.app_name.should == 'my_great_app'
    end

    it "should make the env available" do
      config.env.should == 'staging'
    end
  end

  describe '#connection' do
    context "environmental variables" do
      context 'default behavior' do
        let(:old_value) { ENV['RABBITMQ_URL'] }
        let(:url) { 'http://cloudamqp-url.com' }

        before do
          old_value
          ENV['RABBITMQ_URL'] = url
        end

        after do
          ENV['RABBITMQ_URL'] = old_value
        end

        it "returns the RABBITMQ_URL" do
          config.connection_params.should == url
        end
      end

      context 'additional configuration passed in' do
        let(:old_value) { ENV['SOMEOTHERURL'] }
        let(:url) { 'http://someother-url.com' }
        let(:options) {
          {
            connection_key: 'SOMEOTHERURL'
          }
        }

        before do
          old_value
          ENV['SOMEOTHERURL'] = url
        end

        after do
          ENV['SOMEOTHERURL'] = old_value
        end

        it "returns the url specified in the env" do
          config.connection_params.should == url
        end
      end
    end

    context 'no environmental variables' do
      context 'default' do
        it "uses the default url" do
          config.connection_params.should == {
            :host => '127.0.0.1'
          }
        end
      end

      context 'connection params passed in' do
        let(:options) {
          {
            connection_params: {
              :host => 'hoo.com'
            }
          }
        }

        it "uses what it is given" do
          config.connection_params.should == options[:connection_params]
        end
      end
    end
  end
end
