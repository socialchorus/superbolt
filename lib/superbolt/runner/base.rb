module Superbolt
  module Runner
    class Base
      attr_reader :queue, :error_notifier, :logger, :block

      def initialize(queue, error_notifier, logger, block)
        @queue = queue
        @error_notifier = error_notifier
        @logger = logger
        @block = block
      end

      def channel
        queue.channel
      end

      def on_error(message, error)
        error_notifier.error!(error, message)
      end
    end
  end
end
