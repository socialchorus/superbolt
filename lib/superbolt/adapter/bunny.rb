module Superbolt
  module Adapter
    class Bunny < Base
      def socket
        return @socket if @socket
        @socket = ::Bunny.new(config.connection_params)
        @socket.start
        @socket
      end

      def new_channel
        socket.create_channel
      end

      def channel=(new_channel)
        @channel = new_channel
      end
    end
  end
end
