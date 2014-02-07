require 'spec_helper'

describe 'Superbolt::Queue' do
  let(:name) { 'superbolt_test' }
  let(:connection) { Superbolt::Connection.new }
  let(:queue) { Superbolt::Queue.new(name) }
  let(:messages) { [] }

  before do
    queue.clear
  end

  it "has the right name" do
    queue.name.should == name
  end

  it "is setup with the right defaults" do
    queue.exclusive?.should be_false
    queue.durable?.should be_true
    queue.auto_delete?.should be_false
  end

  describe 'queue/array operations' do
    let(:message) { {hello: 'insomniacs'} }
    let(:message_two) { {:hello => 'early birds'} }

    let(:decoded) { {'hello' => 'insomniacs'} }
    let(:decoded_two) { {'hello' => 'early birds'} }

    describe '#push' do
      let(:bunny_queue) {connection.queue(name, Superbolt::Queue.default_options)}

      it "writes to the queue" do
        queue.push(message)
        queue.size.should == 1
      end
    end

    describe '#peek' do
      it "returns the message but leaves it in the queue" do
        queue.push(message)
        queue.peek.should == decoded
        queue.size.should == 1 
      end
    end

    describe '#pop' do
      it "returns the message and deletes it from the queue" do
        queue.push(message)
        queue.pop.should == decoded
        queue.size.should == 0
      end

      it "leaves all other messages in the queue" do
        queue.push(message)
        queue.push(message_two)
        queue.pop
        queue.size.should == 1
        queue.all.should include(decoded_two)
      end
    end

    describe '#all' do
      before do
        queue.push(message)
        queue.push(message)
        queue.push(message)
      end

      it "returns all the messages on the queue" do
        messages = queue.all
        messages.size.should == 3
        messages.uniq.should == [decoded]
      end

      it "does not consume the messages" do
        queue.size.should == 3
      end
    end

    describe '#slice(offset, n)' do
      before do
        (0..9).to_a.each do |i|
          queue.push(message.merge(i: i))
        end
      end

      it "returns a set of messages determined by the offset and the number requested" do
        messages = queue.slice(1,3)
        messages.size.should == 3
        messages.map{|json| json['i']}.should == [1,2,3]
      end

      it "does not consume messages" do
        queue.slice(1,3)
        queue.size.should == 10
      end
    end

    describe '#[i]' do
      before do
        (0..9).to_a.each do |i|
          queue.push(message.merge(i: i))
        end
      end

      it "return the message at the i-th position without removing it from the queue" do
        json = queue[3]
        json['i'].should == 3
      end
    end

    describe '#delete(&block)' do
      before do
        (0..9).to_a.each do |i|
          queue.push(message.merge(i: i))
        end
      end

      it "returns all messages where the block is true" do
        messages = queue.delete{|json| json['i'] > 2 && json['i'] != 6 && json['i'] < 8 }
        messages.map{|json| json['i']}.should == [3,4,5,7]
      end

      it "removes those messages from the queue" do
        queue.delete{|json| json['i'] > 2 && json['i'] != 6 && json['i'] < 8 }
        queue.size.should == 6
      end
    end
  end
end
