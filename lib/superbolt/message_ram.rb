module Superbolt
  class MessageRam
    attr_reader :messenger, :method_name
    attr_accessor :run_time
    def initialize(messenger, method_name)
      @messenger = messenger
      @method_name = method_name
      @run_time = 0
    end

    def besiege
      messenger.send(method_name)
    rescue => e
      puts "Something went wrong: #{e}"
      puts "=========================="
      puts "Continuing the siege in #{messenger.retry_time} seconds...\n"
      sleep(messenger.retry_time)
      retreat(e) if retreat?
      messenger.live_queue.close
      besiege
    end

    def retreat?
      @run_time += messenger.retry_time
      run_time >= messenger.timeout
    end

    def retreat(error)
      raise error
    end
  end
end
