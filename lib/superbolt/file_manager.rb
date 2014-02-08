module Superbolt
  class FileManager
    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    def perform
      file_keys.each do |key|
        hash[key] = process_file(hash[key])
      end
      hash
    end

    def file_keys
      @file_keys ||= hash.keys.find_all { |key| key.to_s.match(Superbolt.file_matcher) }
    end

    def process_file(arg)
      raise NotImplementedError
    end
  end
end