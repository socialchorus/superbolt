module Superbolt
  module Runner
    class Default < Base
      def run
        set_prefetch
        subscribe
      end

      def set_prefetch
        channel.prefetch(prefetch) if prefetch
      end

      def subscribe
        queue.subscribe(ack: ack) do |metadata, payload|
          message =   IncomingMessage.new(metadata, payload, channel)
          processor = Processor.new(message, logger, &block)
          unless processor.perform
            on_error(message.parse, processor.exception)
          end
          message.ack if ack
        end
      end

      def ack
      end

      def prefetch
      end
    end
  end
end