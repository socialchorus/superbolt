module Superbolt
  module Adapter
    class Bunny < Base
      def socket
        return @socket if @socket
        @socket = ::Bunny.new(config.connection_params)
        @socket.start
        @socket
      end

      def channel
        @channel ||= socket.create_channel
      end
    end
  end
end
