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
        return @channel if @channel 
        tries = 0
        begin
          @channel = connection.new_channel
        rescue ::Bunny::Session::CommandInvalid
          @channel.close
          @channel = nil
          tries += 1
          retry if tries < 2
        end
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

