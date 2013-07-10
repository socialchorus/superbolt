module Superbolt
  class Queue
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

    def self.default_options
      {
        :auto_delete => false,
        :durable => true,
        :exclusive => false
      }
    end

    delegate :exclusive?, :durable?, :auto_delete?,
      to: :q

    def writer
      connection.exchange
    end

    def push(message)
      closing do
        writer.publish(message.to_json, routing_key: name)
      end
    end

    def channel
      connection.channel
    end

    def size
      closing do
        q.message_count
      end
    end

    def clear
      closing do
        q.purge
      end
    end

    def read
      messages = []
      closing do
        q.subscribe(:ack => true) do |delivery_info, metadata, payload|
          message = IncomingMessage.new(delivery_info, payload, channel)
          messages << message
        end
      end
      messages
    end

    def all
      read.map(&:parse)
    end

    def peek
      all.first
    end

    def pop
      messages = []
      closing do
        popped = false
        q.subscribe(:ack => false) do |delivery_info, metadata, message|
          next if popped
          messages << IncomingMessage.new(delivery_info, message, channel)
          popped = true
        end
      end
      message = messages.first
      message && message.parse
    end

    delegate :slice, :[],
      to: :all

    def delete
      messages = []
      closing do
        q.subscribe(:ack => true) do |delivery_info, metadata, payload|
          message = IncomingMessage.new(delivery_info, payload, channel)
          relevant = yield(message.parse)
          if relevant
            messages << message.parse
            message.ack
          end
        end

        # channel is closed by block before message ack can complete
        # therefore we must sleep :(
        sleep 0.02
      end
      messages
    end
  end
end
