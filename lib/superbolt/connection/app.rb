module Superbolt
  module Connection
    class App < Base
      def connection
        CONNECTION
      end

      def close(&block)
        channel.close
        @channel = nil
        @q = nil
        @qq = nil
        block.call
      end

      def qq
        @qq ||= channel.queue("#{name}.quit", self.class.default_options)
      end
    end
  end
end

