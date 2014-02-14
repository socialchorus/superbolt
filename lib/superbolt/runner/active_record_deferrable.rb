module Superbolt
  module Runner
    class ActiveRecordDeferrable < AckOne
      def before_fork
        ActiveRecord::Base.connection.disconnect!
      end

      def after_fork
        ActiveRecord::Base.establish_connection
      end
    end
  end
end