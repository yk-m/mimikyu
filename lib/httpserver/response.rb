require 'httpserver'
require 'time'

module Httpserver
  class Header
    def initialize(response_code, headers, body_length)
      @response_code = response_code
      @headers = {
        "Server" => "mimikyu",
        "Date" => Time.now.httpdate,
        "Connection" => "close",
        "Content-Length" => body_length
      }.merge(headers)
    end

    def to_str
      response = ""
      response << "HTTP/1.0 " + @response_code.to_s + " " + Status[@response_code] + "\n"
      response << @headers.reduce("") { |header, (key, value)|
        if value.to_s == "" then
          next header
        end
        header << key.to_s + ": " + value.to_s + "\n"
      }
      response << "\n"
    end
  end

  class Response
    DOCUMENT_ROOT = "/Users/yuka/GoogleDrive/Study/httpserver/www/html"

    def self.ext_to_mime(ext)
      return "text/plain" if ext == ".txt"
      return "text/html" if ext == ".html"
      return "text/css" if ext == ".css"
      return "image/gif" if ext == ".gif"
      return "image/jpeg" if ext == ".jpeg"
      return "image/jpeg" if ext == ".jpg"
      return "image/png" if ext == ".png"
    end

    def text(status_code, body)
      response = ""
      response << Header.new(status_code, {"Content-Type" => "text/html"}, body.length).to_str
      response << body
    end

    def build(request)
      path = File.join(Response::DOCUMENT_ROOT, request.uri)
      if (!File.file?(path)) then
        raise HttpError.new(404)
      end

      file = File.open(path, 'r')
      content_type = Response::ext_to_mime(File.extname(path))
      response = ""
      response << Header.new(200, {"Content-Type" => content_type}, file.size).to_str
      response << file.read
    end

    def error(e)
      text(e.code, e.message)
    end
  end
end
