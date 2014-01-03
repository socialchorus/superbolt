module Superbolt
  class App
    attr_reader :config, :env
    attr_accessor :logger

    def initialize(name, options={})
      @name = name
      @env = options[:env] || Superbolt.env
      @logger = options[:logger] || Logger.new($stdout)
      @config = options[:config] || Superbolt.config
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

    def quit_subscriber_queue
      connection.qq
    end

    def quit_queue
      Queue.new("#{connection.name}.quit", connection.config)
    end

    def error_queue
      Queue.new("#{connection.name}.error", connection.config)
    end

    def run(&block)
      EventMachine.run do
        queue.subscribe(ack: false) do |metadata, payload|
          message = IncomingMessage.new(metadata, payload, channel)
          processor = Processor.new(message, logger, &block)
          unless processor.perform
            on_error(message.parse, processor.exception)
          end
        end

        quit_subscriber_queue.subscribe do |message|
          quit(message)
        end
      end
    end

    def on_error(message, error)
      error_message = message.merge({error: {
        class: error.class,
        message: error.message,
        backtrace: error.backtrace
      }})
      error_queue.push(error_message)
    end

    def quit(message='no message given')
      logger.info "EXITING Superbolt App listening on queue #{name}: #{message}"
      close {
        EventMachine.stop
      }
    end
  end
end
