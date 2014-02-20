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
        q # to make sure it is connected
        connection.exchange
      end

      def qq
        @qq ||= connection.queue("#{name}.quit", self.class.default_options)
      end
    end
  end
end
