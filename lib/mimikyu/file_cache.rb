require 'mimikyu'
require 'singleton'

module Mimikyu
  class FileCache
    attr_reader :files
    include Singleton
    def initialize()
      @files = {}
      Dir.glob(File.join(Response::DOCUMENT_ROOT, "**/*")) do |item|
        file = File.open(item, 'r')
        @files[item] = file.read
        file.close
      end
    end
  end
end
