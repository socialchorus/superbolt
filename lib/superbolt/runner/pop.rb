module Superbolt
  module Runner
    class Pop < Base
      attr_reader :message

      def run
        EventMachine.add_periodic_timer(0.01) do
          next unless queue.message_count > 0


          queue.pop do |delivery_info, metadata, payload|
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
end