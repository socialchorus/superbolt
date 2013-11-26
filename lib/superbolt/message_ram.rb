module Superbolt
  class MessageRam
    attr_reader :messenger, :method_name, :stdout
    attr_accessor :run_time

    def initialize(messenger, method_name, stdout=$stdout)
      @messenger = messenger
      @method_name = method_name
      @run_time = 0
      @stdout = stdout
    end

    def besiege
      messenger.send(method_name)
    rescue => e
      report(e)
      sleep(retry_time)
      retreat(e) if retreat?
      live_queue.close
      besiege
    end

    def retreat?
      @run_time += retry_time
      run_time >= timeout
    end

    def retreat(error)
      raise error
    end

    delegate :retry_time, :timeout, :live_queue,
      to: :messenger

    def report(error)
      stdout.puts "Something went wrong: #{error}"
      stdout.puts "=========================="
      stdout.puts "Continuing the siege in #{retry_time} seconds...\n"
    end
  end
end
