module Superbolt
  module Adapter
    class Base
      attr_reader :config

      def initialize(config=nil)
        @config = config || Superbolt.config
      end

      delegate :closed?, :open, :open?,
        to: :socket

      def close
        response = socket.close
        @socket = nil
        @channel = nil
        response
      end
    end
  end
end
