module Superbolt
  module Adapter
    class AMQP < Base
      def socket
        @socket ||= ::AMQP.connect(config.connection_params)
      end

      def channel
        @channel ||= ::AMQP::Channel.new(socket)
      end

      def close(&block)
        socket.close(&block)
      end
    end
  end
end

