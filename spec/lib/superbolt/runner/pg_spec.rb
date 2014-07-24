require 'spec_helper'

module ActiveRecord
  class Base
  end
end

module PG
  class UnableToSend
    def self.message
      'oh noes'
    end

    def self.backtrace
      'trace me'
    end
  end

  class ConnectionBad
    def self.message
      'oh noes'
    end

    def self.backtrace
      'trace me'
    end
  end
end

describe "Superbolt::Runner::Pg" do
  let(:runner) { Superbolt::Runner::Pg.new('berkin', Superbolt::ErrorNotifier::None.new, 'whatever', 'some block') }
  let(:connection) { double('connection', reset!: true) }

  before do
    ActiveRecord::Base.stub(:connection).and_return(connection)
  end

  describe "on_error" do
    context "PG::UnableToSend" do
      it "should handle it" do
        connection.should_receive(:reset!).and_return(true)
        runner.on_error({message: 'somethig has gone very wrong'}, PG::UnableToSend)
      end
    end

    context "PG::ConnectionBad " do
      it "should handle it" do
        connection.should_receive(:reset!).and_return(true)
        runner.on_error({message: 'somethig has gone very wrong'}, PG::ConnectionBad)
      end
    end
  end
end
