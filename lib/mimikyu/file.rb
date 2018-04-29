require 'mimikyu'
require 'singleton'

module Mimikyu
  class FileCache
    include Singleton
    def initialize()
      @files = {}
      Dir.glob(File.join(Response::DOCUMENT_ROOT, "**/*")) do |item|
        file = File.open(item, 'r')
        @files[item] = file.read
        file.close
      end
    end

    def [](key)
      @files[key]
    end

    def has_key?(key)
      @files.has_key?(key)
    end
  end
end
