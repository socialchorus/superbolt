module Superbolt
  class IncomingMessage
    attr_reader :payload, :tag, :channel

    def initialize(delivery_info, payload, channel)
      @payload = payload
      @tag = delivery_info.delivery_tag
      @channel = channel
    end

    def parse
      JSON.parse(payload)
    rescue JSON::ParserError
      payload
    end

    def reject
      channel.reject(tag)
    end

    def ack
      channel.acknowledge(tag)
    end
  end
end

