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
        name = config.app_name + '_' + config.env
        channel.fanout(name + '.error')
        channel.fanout(name + '.quit')
        channel.fanout(name)
      end
    end
  end
end
