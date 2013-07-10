module Superbolt
  class App
    attr_reader :config, :env
    attr_accessor :logger

    def initialize(name, options)
      @name = name
      @env = options[:env]
      @logger = options[:logger] || Logger.new($stdout)
      @config = options[:config] || Config.new
    end

    def name
      env ? "#{@name}_#{env}" : @name
    end

    def connection
      @connection ||= Connection::App.new(name, config)
    end

    delegate :close, :closing, :exclusive?, :durable?, :auto_delete?,
      :writer, :channel, :q,
        to: :connection

    def queue
      connection.q
    end

    def quit_queue
      connection.qq
    end

    def run(&block)
      EventMachine.run do
        queue.subscribe(ack: true) do |metadata, payload|
          message = IncomingMessage.new(metadata, payload, channel)
          if Processor.new(message, logger, &block).perform
            message.ack
          end
        end

        quit_queue.subscribe do |message|
          quit(message)
        end
      end
    end

    def quit(message='no message given')
      logger.info "EXITING Superbolt App listening on queue #{name}: #{message}"
      close {
        EventMachine.stop { exit }
      }
    end
  end
end
