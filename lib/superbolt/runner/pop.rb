module Superbolt
  module Runner
    class Pop < Base
      attr_reader :message
    
      def run
        EventMachine.add_periodic_timer(0.01) do
          next if message

          queue.pop do |metadata, payload|
            @message = IncomingMessage.new(metadata, payload, channel)
            processor = Processor.new(message, logger, &block)

            unless processor.perform
              on_error(message.parse, processor.exception)
            end
            @message = nil
          end
        end
      end
    end
  end
end