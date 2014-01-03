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
      :writer, :channel, :q,
        to: :connection

    def push(message)
      closing do
        writer.publish(message.to_json, routing_key: name)
      end
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

    # TODO: roll up some of these subscribe methods

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
      message = pop
      push(message)
      message
    end

    def pop
      closing do
        q.pop do |delivery_info, metadata, message|
          message = IncomingMessage.new(delivery_info, message, channel)
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
