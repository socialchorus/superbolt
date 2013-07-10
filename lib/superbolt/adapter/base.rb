module Superbolt
  module Adapter
    class Base
      attr_reader :config

      def initialize(config=Config.new)
        @config = config
      end

      delegate :closed?, :open, :open?,
        to: :socket

      def close
        response = socket.close
        @socket = nil
        @channel = nil
        response
      end

      delegate :queues, :acknowledge, :reject, :queue,
        to: :channel

      def exchange
        channel.default_exchange
      end
    end
  end
end
