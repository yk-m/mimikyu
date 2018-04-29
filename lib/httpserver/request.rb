require 'httpserver'

module Httpserver
  class Request
    attr_reader :method, :uri, :http_version
    def initialize(client)
      request_line = client.gets.split(" ")
      if request_line.length != 3 then
        raise HttpError.new(400)
      end
      @method = request_line[0].upcase
      @uri = request_line[1]
      @http_version = request_line[2]
    end
  end
end
