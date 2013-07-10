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

    delegate :close, :closed?, :open, :open?,
      to: :socket

    delegate :queues, :default_exchange, :acknowledge, :reject, :queue,
      to: :channel
  end
end
