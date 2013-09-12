module Superbolt
  module Connection
    class App < Base
      def connection
        @connection ||= Adapter::Bunny.new(config)
      end

      def close(&block)
        connection.close(&block)
        @connection = nil
        @q = nil
        @qq = nil
      end

      def qq
        @qq ||= connection.queue("#{name}.quit", self.class.default_options)
      end
    end
  end
end

