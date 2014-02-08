require 'spec_helper'

describe Superbolt::FilePacker do
  let(:packer) { Superbolt::FilePacker.new(hash) }

  let(:hash) { 
    { 
      my_file: file,
      foo: 'bar'
    }
  }

  let(:dumper) { double('dumper', to_hash: {}) }

  let(:file) { double('file') }
  
  describe '#perform' do
    it "makes matching keys into a file hash via FileMarshal" do
      FileMarshal::Dumper.should_receive(:new).with(file).and_return(dumper)
      dumper.should_receive(:to_hash)
      packer.perform.should == {
        foo: 'bar',
        my_file: {}
      }
    end
  end
end