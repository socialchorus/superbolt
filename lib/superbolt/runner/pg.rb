module Superbolt
  module Runner
    class Pg < AckOne
      def on_error(message, error)
        if reconnect_after_error?(error)
          ActiveRecord::Base.connection.reconnect!
        end

        super
      end

      private

      def reconnect_after_error?(error)
        error.is_a?(ActiveRecord::StatementInvalid) and
          error.message.start_with?("PG::UnableToSend") or
          error.message.start_with?("PG::ConnectionBad")
      end
    end
  end
end
