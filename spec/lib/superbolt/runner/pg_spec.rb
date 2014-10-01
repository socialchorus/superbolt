require 'spec_helper'

module ActiveRecord
  class Base
    def self.connection
      @@connection
    end

    @@connection = Class.new do
      def self.reset!
      end
    end
  end

  class StatementInvalid < StandardError
  end
end

PG_UNABLE_TO_SEND_ERROR = ActiveRecord::StatementInvalid.new("PG::UnableToSend: server closed the connection unexpectedly\n\tThis probably means the server terminated abnormally\n\tbefore or while processing the request.\n: SELECT  \"data_sources\".* FROM \"data_sources\"  WHERE \"data_sources\".\"program_id\" = 1 AND \"data_sources\".\"identifier\" = 'qz.com/feed'  ORDER BY \"data_sources\".\"id\" ASC LIMIT 1")

PG_CONNECTION_BAD_ERROR = ActiveRecord::StatementInvalid.new("PG::ConnectionBad: PQsocket() can't get socket descriptor: BEGIN")

describe "Superbolt::Runner::Pg" do
  subject(:runner) { Superbolt::Runner::Pg.new('berkin', Superbolt::ErrorNotifier::None.new, 'whatever', 'some block') }

  describe "#on_error" do
    it "reconnects ActiveRecord when it gets PG::UnableToSend" do
      expect(ActiveRecord::Base.connection).to receive(:reconnect!)
      report_error(PG_UNABLE_TO_SEND_ERROR)
    end

    it "reconnects ActiveRecord when it gets PG::ConnectionBad" do
      expect(ActiveRecord::Base.connection).to receive(:reconnect!)
      report_error(PG_CONNECTION_BAD_ERROR)
    end

    it "doesn't reconnect for AR::StatementInvalid with a different message" do
      expect(ActiveRecord::Base.connection).to_not receive(:reconnect!)
      report_error(ActiveRecord::StatementInvalid.new("some other message"))
    end
  end

  def report_error(exception)
    runner.on_error({"superbolt_message_payload" => "hello"}, exception)
  end
end
