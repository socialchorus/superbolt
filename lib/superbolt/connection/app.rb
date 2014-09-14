module Superbolt
  module Connection
    class App < Base
      def connection
        @connection ||= Adapter::AMQP.new(config)
      end

      def close(&block)
        connection.close(&block)
        @connection = nil
        @q = nil
      end
    end
  end
end

