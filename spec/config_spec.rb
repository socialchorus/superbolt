require 'rails_helper'

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
      expect(config.app_name).to eq('my_great_app')
    end

    it "should make the env available" do
      expect(config.env).to eq('staging')
    end
  end

  describe '#statsd_host' do
    let(:options) {
      {
        statsd_host: "localhost"
      }
    }
    it "should make the statsd_host available" do
      expect(config.statsd_host).to eq('localhost')
    end
  end

  describe '#statsd_port' do
    let(:options) {
      {
        statsd_port: 8125
      }
    }
    it "should make the statsd_port available" do
      expect(config.statsd_port).to eq(8125)
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
          expect(config.connection_params).to eq(url)
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
          expect(config.connection_params).to eq(url)
        end
      end
    end

    context 'no environmental variables' do
      context 'default' do
        it "uses the default url" do
          expect(config.connection_params).to eq({
            :host => '127.0.0.1'
          })
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
          expect(config.connection_params).to eq(options[:connection_params])
        end
      end
    end
  end
end
