module Superbolt
  module Runner
    class Pop < Base
      attr_reader :message

      def run
        queue.subscribe(ack: false, block: true) do |delivery_info, metadata, payload|
          @message = IncomingMessage.new(delivery_info, payload, channel)
          processor = Processor.new(message, logger, &block)
          unless processor.perform
            on_error(message.parse, processor.exception) if message.parse
          end
          @message = nil
        end
      end
    end
  end
end
