module Superbolt
  class IncomingMessage
    attr_reader :payload, :tag, :channel

    def initialize(delivery_info, payload, channel)
      @payload = payload
      @tag = delivery_info.delivery_tag if delivery_info
      @channel = channel
    end

    def parse
      hash = JSON.parse(payload)
      unpack_files(hash)
    rescue JSON::ParserError
      payload
    end

    def reject(requeue=true)
      channel.reject(tag, requeue)
    end

    def ack
      channel.acknowledge(tag)
    end

    def unpack_files(hash)
      return hash unless hash.is_a?(Hash) && hash["arguments"].is_a?(Hash)
      hash['arguments'] = FileUnpacker.new(hash["arguments"]).perform
      hash
    end
  end
end