module Superbolt
  class Processor
    attr_reader :message, :logger, :block
    attr_accessor  :start_time, :exception

    def initialize(message, logger, &block)
      @message = message
      @logger = logger
      @block = block
    end

    def perform
      start!
      block.call(message.parse, logger)
      finish!
      true
    rescue Exception => e
      self.exception = e
      logger.error("#{e.message}\n#{e.backtrace}")
      false
    end

    def start!
      self.start_time = Time.now
      logger.info "[#{start_time}] Processing message: #{message.parse}"
    end

    def finish!
      end_time = Time.now
      logger.info "[#{end_time}] Finished message: #{message.parse}\n  in #{start_time - end_time} seconds"
    end
  end
end
