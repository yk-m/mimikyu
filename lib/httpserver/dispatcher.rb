require 'httpserver'
require 'time'

module Httpserver
  class Dispatcher
    def run(client)
      begin
        request = Request.new(client)
        status_line, header, body = Response.new.file(request)
      rescue HttpError => e
        status_line, header, body = Response.new.text(e.code, e.message)
        p e
      end

      return status_line + header + "\n" + body if request.method == "GET"
      return status_line + header if request.method == "HEAD"
    end
  end
end
