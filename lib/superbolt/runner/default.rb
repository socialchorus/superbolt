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
        queue.subscribe(ack: ack, block: true) do |delivery_info, metadata, payload|
          message = Superbolt::IncomingMessage.new(delivery_info, payload, channel)
          processor = processor_class.new(message, logger, &block)
          success = processor.perform

          unless success
            on_error(message.parse, processor.exception)
          end

          message.ack if ack
        end
      end

      def ack
      end

      def prefetch
      end

      def processor_class
        Superbolt::Processor
      end
    end
  end
end
