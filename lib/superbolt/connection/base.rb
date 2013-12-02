module Superbolt
  module Connection
    class Base
      attr_reader :name, :config

      def initialize(name, config=nil)
        @name = name
        @config = config || Superbolt.config
      end

      def connection
        raise NotImplementedError
      end

      def close
        raise NotImplementedError
      end

      def q
        @q ||= channel.queue(name, self.class.default_options)
      end

      delegate :exclusive?, :durable?, :auto_delete?,
        to: :q

      def channel
        @channel ||= connection.new_channel
      end
      
      def self.default_options
        {
          :auto_delete => false,
          :durable => true,
          :exclusive => false
        }
      end
    end
  end
end

