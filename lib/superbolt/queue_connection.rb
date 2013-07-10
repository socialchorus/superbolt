module Superbolt
  class QueueConnection
    attr_reader :name, :config

    def initialize(name, config=nil)
      @name = name
      @config = config || Config.new
    end

    def connection
      @connection ||= Connection.new(config)
    end

    def close
      connection.close
      @connection = nil
      @q = nil
    end

    def closing(&block)
      response = block.call
      close
      response
    end

    def q
      @q ||= connection.queue(name, self.class.default_options)
    end

    delegate :exclusive?, :durable?, :auto_delete?,
      to: :q

    def writer
      connection.exchange
    end

    def channel
      connection.channel
    end

    def self.default_options
      {
        :auto_delete => false,
        :durable => true,
        :exclusive => false
      }
    end
  end
end
