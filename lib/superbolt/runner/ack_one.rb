module Superbolt
  module Runner
    class AckOne < Default
      def ack
        true
      end

      def prefetch
        1
      end
    end
  end
end