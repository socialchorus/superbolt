module Superbolt
  class FileUnpacker < FileManager
    def process_file(file_hash)
      FileMarshal::Loader.new(file_hash).tempfile
    end
  end
end