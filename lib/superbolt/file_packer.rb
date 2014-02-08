module Superbolt
  class FilePacker < FileManager
    def process_file(file)
      FileMarshal::Dumper.new(file).to_hash
    end
  end
end