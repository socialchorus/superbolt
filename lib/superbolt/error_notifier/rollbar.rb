module Superbolt
  module ErrorNotifier
    class Rollbar
      def initialize(logger)
        @logger = logger
      end

      def error!(exception, superbolt_message = nil)
        if defined? ::Rollbar
          ::Rollbar.error(exception, superbolt_message)
        else
          @logger.warn("You have configured Superbolt to send errors to Rollbar, but Rollbar is not available or is not configured!")
        end
      end
    end
  end
end
