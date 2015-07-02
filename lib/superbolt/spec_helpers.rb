module Superbolt
  module SpecHelpers
    def superbolt_message
      superbolt_message = messenger_class.new
      allow(superbolt_message).to receive(:send!) do |args|
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
      allow(Superbolt).to receive(:message) { |args| superbolt_message }
    end

    def messenger_class
      Superbolt::Messenger
    end
  end
end
