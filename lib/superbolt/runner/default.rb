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
          #Thanks again to LShift for this solution to long-running processes
          #Defer keeps heartbeat running while the process finishes
          EM.defer do
            # this gets run on the thread pool
            message = Superbolt::IncomingMessage.new(metadata, payload, channel)
            processor = Superbolt::Processor.new(message, logger, &block)
            unless processor.perform
              on_error(message.parse, processor.exception)
            end

            EM.next_tick do
              # this gets run back on the main loop
              message.ack if ack
            end
          end
        end
      end

      def ack
      end

      def prefetch
      end
    end
  end
end