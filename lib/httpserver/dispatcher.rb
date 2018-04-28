require 'httpserver'
require 'time'

module Httpserver
  class Dispatcher
    def run(client)
      response = Response.new
      begin
        request = Request.new(client)
        return response.build(request)
      rescue HttpError => e
        return response.error(e)
      end
    end
  end
end
