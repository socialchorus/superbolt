module Superbolt
  class Messenger
    attr_accessor :origin, :name, :event, :arguments, :env, :retry_time, :timeout, :live_queue

    def initialize(options={})
      @name = options.delete(:to)
      @origin = options.delete(:from) || Superbolt.app_name
      @event = options.delete(:event) || self.class.defaultevent
      @env = Superbolt.env
      @arguments = options
      @retry_time = Superbolt.config.options[:retry_time] || 10
      @timeout = Superbolt.config.options[:timeout] || 60
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

    def retry_after(val=nil)
      attr_chainer(:retry_time, val)
    end

    def timeout_after(val=nil)
      attr_chainer(:timeout, val)
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
      queue.push(message)
      # MessageRam.new(self, :push_to_queue).besiege
    end

    def push_to_queue
      queue.push(message)
    end

    def queue
      unless name
        raise "no destination app name defined, please pass one in"
      end
      @live_queue = Queue.new(destination_name)
    end

    def destination_name
      "#{name}_#{env}"
    end

    def self.defaultevent
      'default'
    end
  end
end
