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
    def to(val)
      self.name = val
      self
    end

    def from(val)
      self.origin = val
      self
    end

    def re(val)
      self.event = val
      self
    end

    def data(val)
      self.arguments = val
      self
    end

    # alias
    # -------

    def send!(args=nil)
      self.arguments = args if args
      queue.push(message)
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
