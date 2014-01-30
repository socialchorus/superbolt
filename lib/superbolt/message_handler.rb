# Subclass me to get an easy MessageHandler to plug into your router, no boilerplate.
# Just focus on the perform method that you need to build.
module Superbolt
  class MessageHandler
    attr_reader :arguments, :logger

    def initialize(arguments, logger)
      @arguments = arguments
      @logger = logger
      parse_arguments
    end

    def parse_arguments
      # override if you want to extract important stuff at initialize
    end

    def perform
      raise NotImplementedError
    end
  end
end