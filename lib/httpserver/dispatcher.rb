require 'httpserver'
require 'time'

module Httpserver
  class Dispatcher
    Allowed_Methods = ["HEAD", "GET"]
    def run(client)
      begin
        request = Request.new(client)
        if !Allowed_Methods.include?(request.method) then
          raise HttpError.new(405)
        end
        status_line, header, body = Response.new.file(request)
      rescue HttpError => e
        status_line, header, body = Response.new.text(e.code, e.message)
      rescue => e
        e = HttpError.new(500)
        status_line, header, body = Response.new.text(e.code, e.message)
      end

      return status_line + header if request.method == "HEAD"
      return status_line + header + "\n" + body
    end
  end
end
