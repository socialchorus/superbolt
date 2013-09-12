module Superbolt
  module Connection
    class App < Base
      def connection
        @connection ||= Adapter::Bunny.new(config)
      end

      def close(&block)
        connection.close
        @connection = nil
        @q = nil
        @qq = nil
        block.call
      end

      def qq
        @qq ||= connection.queue("#{name}.quit", self.class.default_options)
      end
    end
  end
end

