module Superbolt
  class Messenger
    attr_accessor :origin, :name, :_event, :arguments, :env

    def initialize(options={})
      @name = options.delete(:to)
      @origin = options.delete(:from) || Superbolt.app_name
      @_event = options.delete(:event) || self.class.default_event
      @env = Superbolt.env
      @arguments = options
    end

    def message
      {
        origin: origin,
        event: _event,
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

    def event(val)
      self._event = val
      self
    end

    def data(val)
      self.arguments = val
      self
    end

    # alias
    # -------

    def send!
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

    def self.default_event
      'default'
    end
  end
end
