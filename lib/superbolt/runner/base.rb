module Superbolt
  module Runner
    class Base
      attr_reader :queue, :error_queue, :logger, :block

      def initialize(queue, error_queue, logger, block)
        @queue = queue
        @error_queue = error_queue
        @logger = logger
        @block = block
      end

      def channel
        queue.channel
      end

      def on_error(message, error)
        error_message = message.merge({error: {
          class: error.class,
          message: error.message,
          backtrace: error.backtrace,
          errored_at: Time.now
        }})
        error_queue.push(error_message)
      end
    end
  end
end