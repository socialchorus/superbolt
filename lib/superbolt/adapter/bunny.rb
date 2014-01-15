module Superbolt
  module Adapter
    class Bunny < Base
      def socket
        Thread.current[:bunny_socket] ||= establish_socket
      end

      def establish_socket
        socket = ::Bunny.new(config.connection_params)
        socket.start
        socket
      end

      def channel
        @channel ||= socket.create_channel
      end

      def close
        response = channel.close
        @channel = nil
        response
      end
    end
  end
end
