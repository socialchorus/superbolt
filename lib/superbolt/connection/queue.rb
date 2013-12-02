module Superbolt
  module Connection
    class Queue < Base
      def connection
        CONNECTION
      end

      def close
        channel.close
        @channel = nil
        @q = nil
      end

      def closing(&block)
        response = block.call
        close
        response
      end
    end
  end
end
