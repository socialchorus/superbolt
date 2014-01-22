module Superbolt
  module SpecHelpers
    def superbolt_message
      superbolt_message = Superbolt::Messenger.new
      superbolt_message.stub(:send!) do |args|
        superbolt_message.data(args)
        superbolt_messages << superbolt_message
      end

      superbolt_message
    end

    def last_superbolt_message
      superbolt_messages.last
    end

    def superbolt_messages
      @superbolt_messages ||= []
    end

    def stub_superbolt_messenger
      Superbolt.stub(:message) { |args| superbolt_message }
    end
  end
end
