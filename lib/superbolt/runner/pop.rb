module Superbolt
  module Runner
    class Pop < Default
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
        false
      end

      def prefetch
        1
      end
    end
  end
end
