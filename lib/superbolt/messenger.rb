require 'airbrake'
module Superbolt
  class Messenger
    attr_accessor :origin, :name, :event, :arguments, :env

    def initialize(options={})
      @name = options.delete(:to)
      @origin = options.delete(:from) || Superbolt.app_name
      @event = options.delete(:event) || self.class.defaultevent
      @env = Superbolt.env
      @arguments = options
    end

    def message
      {
        origin: origin,
        event: event,
        arguments: arguments
      }
    end

    # chainer methods
    #
    def to(val=nil)
      attr_chainer(:name, val)
    end

    def from(val=nil)
      attr_chainer(:origin, val)
    end

    def re(val=nil)
      attr_chainer(:event, val)
    end

    def data(val=nil)
      attr_chainer(:arguments, val)
    end

    def attr_chainer(attr, val)
      return send(attr) unless val
      self.send("#{attr}=", val)
      self
    end

    # alias
    # -------

    def send!(args=nil)
      self.arguments = args if args
      begin
        queue.push(message)
      rescue Bunny::TCPConnectionFailedForAllHosts => e
        Airbrake.notify(e)
      end
    end

    def queue
      unless name
        raise "no destination app name defined, please pass one in"
      end
      Queue.new(destination_name)
    end

    def destination_name
      "#{name}_#{env}"
    end

    def self.defaultevent
      'default'
    end
  end
end
