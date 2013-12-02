module Superbolt
  class Queue
    attr_reader :name, :config

    def initialize(name, config=nil)
      @name = name
      @config = config || Superbolt.config
    end

    def connection
      @connection ||= Connection::Queue.new(name, config)
    end

    delegate :close, :closing, :exclusive?, :durable?, :auto_delete?,
    :channel, :q,
    to: :connection

    def push(message)
      closing do
        q.publish(message.to_json)
      end
    end

    def size
      q.message_count
    end

    def clear
      q.purge
    end

    # TODO: roll up some of these subscribe methods

    def read
      current_size = size
      messages = []
      closing do
        q.subscribe(:ack => true) do |delivery_info, metadata, payload|
          message = IncomingMessage.new(delivery_info, payload, channel)
          messages << message
        end
        while messages.length < current_size
          true  
        end
      end
      messages
    end

    def all
      read.map(&:parse)
    end

    def peek
      message = pop
      push(message)
      message
    end

    def pop
      closing do
        q.pop(ack: false) do |delivery_info, metadata, payload|
          message = IncomingMessage.new(delivery_info, payload, channel) if payload
          message && message.parse
        end
      end
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
