module Superbolt
  module Connection
    class Queue < Base
      def connection
        @connection ||= Adapter::Bunny.new(config)
      end

      def close
        connection.close
        @connection = nil
        @q = nil
      end

      def closing(&block)
        response = block.call
        close
        response
      end

      def writer
        connection.exchange
      end
    end
  end
end
