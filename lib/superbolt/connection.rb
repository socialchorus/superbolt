module Superbolt
  class Connection
    attr_reader :config

    def initialize(config=Config.new)
      @config = config
    end

    def socket
      return @socket if @socket
      @socket = Bunny.new(config.connection_params)
      @socket.start
      @socket
    end

    def channel
      @channel ||= socket.create_channel
    end

    delegate :closed?, :open, :open?,
      to: :socket

    def close
      response = socket.close
      @channel = nil
      @socket = nil
      response
    end

    delegate :queues, :acknowledge, :reject, :queue,
      to: :channel

    def exchange
      channel.default_exchange
    end
  end
end
