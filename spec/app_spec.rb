require 'spec_helper'

describe Superbolt::App do
  let(:app) {
    Superbolt::App.new(name, {
      env: env,
      logger: logger,
      runner: runner_type
    })
  }

  let(:env)         { 'test' }
  let(:name)        { 'superbolt' }
  let(:logger)      { Logger.new('/dev/null') }
  let(:queue)       { Superbolt::Queue.new("#{name}_#{env}") }
  let(:quit_queue)  { Superbolt::Queue.new("#{name}_#{env}.quit") }
  let(:error_queue) { Superbolt::Queue.new("#{name}_#{env}.error") }
  let(:messages)    { [] }

  before do
    queue.clear
    quit_queue.clear
    error_queue.clear
  end

  shared_examples 'app' do
    it "shuts down with any message to the quit queue" do
      queue.push({please: 'stop'})

      app.run do |arguments|
        quit_queue.push({message: 'just because'})
      end

      queue.size.should == 0
      quit_queue.size.should == 0
    end

    it 'passes messages to the block for processing' do
      queue.push({first: 1})
      queue.push({last: 2})

      app.run do |message, logger|
        messages << message
        quit_queue.push({message: 'quit'}) if message['last']
      end

      messages.size.should == 2
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

      queue.size.should == 0
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

      queue.size.should == 0
      error_queue.size.should == 1
    end
  end

  context 'when runner acknowledges one' do
    let(:runner_type) { :ack_one }

    it_should_behave_like "app"
  end

  context 'when runner acknowledges one and uses activerecord deferrable' do
    let(:runner_type) { :ar_deferrable }

    it_should_behave_like "app"
  end

  context 'when runner acknowledges without a prefetch limit' do
    let(:runner_type) { :ack }

    it_should_behave_like 'app'
  end

  context 'when runner does not acknowledge and has no limits' do
    let(:runner_type) { :greedy }

    it_should_behave_like 'app'
  end

  context 'when the runner pops without acknowledgment' do
    let(:runner_type) { :pop }

    it_should_behave_like "app"
  end
end
