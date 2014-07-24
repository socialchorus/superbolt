module Superbolt
  module ErrorNotifier
    class Airbrake
      def initialize(logger)
        @logger = logger
      end

      def error!(exception, superbolt_message = nil)
        if defined? ::Airbrake
          ::Airbrake.notify_or_ignore(exception, parameters: superbolt_message)
        else
          @logger.warn("You have configured Superbolt to send errors to Airbrake, but Airbrake is not available or is not configured!")
        end
      end
    end
  end
end
