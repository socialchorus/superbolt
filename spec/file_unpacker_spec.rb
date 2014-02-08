require 'spec_helper'

describe Superbolt::FileUnpacker do
  let(:unpacker){ Superbolt::FileUnpacker.new(hash) }
  let(:file) { File.open(File.dirname(__FILE__) + '/support/commodore.jpg')}
  let(:file_hash) {
    # back and forth in JSON required due to Time.parse issues
    JSON.parse(FileMarshal::Dumper.new(file).to_hash.to_json)
  }
  let(:hash) { 
    { 
      my_file: file_hash,
      foo: 'bar'
    }
  }

  describe "#perform" do 
    it "makes the keys matching the Superbolt.file_matcher" do
      unpacker.perform[:my_file].should be_a Tempfile
    end

    it "leaves everything else alone" do
      unpacker.perform[:foo].should == "bar"
    end
  end
end