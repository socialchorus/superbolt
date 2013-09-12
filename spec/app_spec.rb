require 'spec_helper'

describe Superbolt::App do
  let(:env)         { 'test' }
  let(:name)        { 'superbolt' }
  let(:logger)      { Logger.new("/dev/null") }
  let(:app)         {
                       Superbolt::App.new(name, {
                         env: env,
                         logger: logger
                       })
                    }
  let(:queue)       { Superbolt::Queue.new("#{name}_#{env}") }
  let(:quit_queue)  { Superbolt::Queue.new("#{name}_#{env}.quit") }
  let(:error_queue) { Superbolt::Queue.new("#{name}_#{env}.error") }
  let(:messages)    { [] }

  before do
    queue.clear
    quit_queue.clear
    error_queue.clear
  end

  describe '#run' do
    it "shuts down with any message to the quit queue" do
      puts 'pushing so hard'
      queue.push({please: 'stop'})
      puts 'about to run'
      app.run do |arguments|
        puts "RUN!!!!!!!!"
        quit_queue.push({message: 'just because'})
        puts 'pushed to quit_queue'
      end
      #puts "done running, tired here da queue message_count #{queue.status}"
      #queue.message_count.should == 0
      #quit_queue.message_count.should == 0
    end

    it 'passes messages to the block for processing' do
      queue.push({first: 1})
      queue.push({last: 2})

      app.run do |message, logger|
        messages << message
        quit_queue.push({message: 'quit'}) if message['last']
      end

      messages.message_count.should == 2
      messages.should == [
        {'first' => 1},
        {'last' => 2}
      ]
    end

    it 'removes messages from the queue on successful completion' do
      queue.push({first: 1})
      queue.push({last: 2})

      app.run do |message, logger|
        messages << message
        quit_queue.push({message: 'quit'}) if message['last']
      end

      queue.message_count.should == 0
    end


    it "passes a logger to the block" do
      mock_logger = double
      app.logger = mock_logger

      message_received = false
      mock_logger.stub(:info) do |m|
        if m == {'write' => 'out'}
          message_received = true
        end
      end

      queue.push({write: 'out'})

      app.run do |message, logger|
        logger.info(message)
        quit_queue.push({message: 'stop!'})
      end

      message_received.should be_true
    end

    it "moves the message to an error queue if an exception is raised" do
      queue.push({oh: 'noes'})

      app.run do |message|
        quit_queue.push({message: 'halt thyself'})
        raise "something went wrong"
      end

      queue.message_count.should == 0
      error_queue.message_count.should == 1
    end
  end
end
