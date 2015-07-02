require 'rails_helper'

describe 'Superbolt::Queue' do
  let(:name) { 'superbolt_test' }
  let(:connection) { Superbolt::Connection.new }
  let(:queue) { Superbolt::Queue.new(name) }
  let(:messages) { [] }

  before do
    queue.clear
  end

  it "has the right name" do
    expect(queue.name).to eq(name)
  end

  it "is setup with the right defaults" do
    expect(queue.exclusive?).to eq(false)
    expect(queue.durable?).to eq(true)
    expect(queue.auto_delete?).to eq(false)
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
        expect(queue.size).to eq(1)
      end
    end

    describe '#peek' do
      it "returns the message but leaves it in the queue" do
        queue.push(message)
        expect(queue.peek).to eq(decoded)
        expect(queue.size).to eq(1)
      end
    end

    describe '#pop' do
      it "returns the message and deletes it from the queue" do
        queue.push(message)
        expect(queue.pop).to eq(decoded)
        expect(queue.size).to eq(0)
      end

      it "leaves all other messages in the queue" do
        queue.push(message)
        queue.push(message_two)
        queue.pop
        expect(queue.size).to eq(1)
        expect(queue.all).to include(decoded_two)
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
        expect(messages.size).to eq(3)
        expect(messages.uniq).to eq([decoded])
      end

      it "does not consume the messages" do
        expect(queue.size).to eq(3)
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
        expect(messages.size).to eq(3)
        expect(messages.map{|json| json['i']}).to eq([1,2,3])
      end

      it "does not consume messages" do
        queue.slice(1,3)
        expect(queue.size).to eq(10)
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
        expect(json['i']).to eq(3)
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
        expect(messages.map{|json| json['i']}).to eq([3,4,5,7])
      end

      it "removes those messages from the queue" do
        queue.delete{|json| json['i'] > 2 && json['i'] != 6 && json['i'] < 8 }
        expect(queue.size).to eq(6)
      end
    end
  end

  describe 'errors cases' do
    let(:new_queue) { Superbolt::Queue.new("random.name.#{rand(1_000_000)}") }

    after do
      new_queue.clear
    end

    it "should store messages to a queue, even when writing before declaring the queue" do
      new_queue.push({my: 'message'})
      expect(new_queue.size).to eq(1)
    end
  end
end
