module Superbolt
  class Router
    attr_reader :message, :logger

    def initialize(message, logger)
      @message = message
      @logger = logger
    end

    def event
      message['event']
    end

    def arguments
      message['arguments'].symbolize_keys
    end

    def handler_class
      self.class.routes[event] && self.class.routes[event].constantize
    end

    def perform
      if handler_class
        handler_class.new(arguments, logger).perform
      else
        logger.warn "No Superbolt route for event: '#{event}'"
      end
    end

    def self.routes
      @routes ||= {} # set this up
    end

    def self.routes=(r)
      @routes = r
    end
  end
end