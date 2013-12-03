module Superbolt
  module Connection
    class Queue < Base
      def connection
        CONNECTION
      end

      def close
        channel.close
        @channel = nil if channel.closed?
        @q = nil if channel.closed?
      end

      def closing(&block)
        response = block.call
        close
        response
      end
    end
  end
end
