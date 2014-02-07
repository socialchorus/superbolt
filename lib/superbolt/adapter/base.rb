module Superbolt
  module Adapter
    class Base
      attr_reader :config

      def initialize(config=nil)
        @config = config || Superbolt.config
        exchange # to make sure the exchange exists
      end

      delegate :closed?, :open, :open?,
        to: :socket

      delegate :queues, :acknowledge, :reject, :queue,
        to: :channel

      def exchange
        channel.fanout(exchange_name + '.error')
        channel.fanout(exchange_name + '.quit')
        channel.fanout(exchange_name)
      end

      def exchange_name
        config.app_name + '_' + config.env
      end
    end
  end
end
