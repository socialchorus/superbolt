module Superbolt
  class App
    attr_reader :config, :env
    attr_accessor :logger

    def initialize(name, options={})
      @name = name
      @env =            options[:env] || Superbolt.env
      @logger =         options[:logger] || Logger.new($stdout)
      @config =         options[:config] || Superbolt.config
    end

    def name
      env ? "#{@name}_#{env}" : @name
    end

    # just in case you have a handle to the app and want to quit it
    def quit_queue
      Queue.new("#{connection.name}.quit", connection.config)
    end

    def error_queue
      Queue.new("#{connection.name}.error", connection.config)
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

    def run(&block)
      EventMachine.run do
        queue.channel.auto_recovery = true

        # LShift came up with this solution, which helps reconnect when
        # a process runs longer than the heartbeat (and therefore disconnects)
        queue.channel.connection.on_tcp_connection_loss do |conn, settings|
          puts 'Lost TCP connection, reconnecting'
          conn.reconnect(false, 2)
        end

        runner_class.new(queue, error_queue, logger, block).run

        quit_subscriber_queue.subscribe do |message|
          quit(message)
        end
      end
    end

    def runner_class
      runner_map[config.runner_type] || default_runner
    end

    def runner_map
      {
        pop:      Runner::Pop,
        ack_one:  Runner::AckOne,
        ack:      Runner::Ack,
        greedy:   Runner::Greedy,
        ar_deferrable: Runner::ActiveRecordDeferrable
      }
    end

    def default_runner
      runner_map[:ack_one]
    end

    def quit(message='no message given')
      logger.info "EXITING Superbolt App listening on queue #{name}: #{message}"
      close {
        EventMachine.stop
      }
    end
  end
end
