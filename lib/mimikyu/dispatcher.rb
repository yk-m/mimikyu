require 'mimikyu'
require 'time'

module Mimikyu
  class Dispatcher
    Allowed_Methods = ["HEAD", "GET"]
    def wrapper(client)
      begin
        request = Request.new(client)
        status_line, header, body = yield(request)
      rescue HttpError => e
        status_line, header, body = Response.new.text(e.code, e.message)
      rescue => e
        e = HttpError.new(500)
        status_line, header, body = Response.new.text(e.code, e.message)
      end

      return status_line + header if request.method == "HEAD"
      return status_line + header + "\n" + body
    end

    def run(client)
      wrapper(client) { |request|
        if !Allowed_Methods.include?(request.method) then
          raise HttpError.new(405)
        end
        Response.new.file(request)
      }
    end

    def cgi(client)
      wrapper(client) { |request|
        Response.new.cgi(request)
      }
    end
  end
end
