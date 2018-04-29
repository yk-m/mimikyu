require 'httpserver'
require 'time'

module Httpserver
  class StatusLine
    def build(response_code)
      "HTTP/1.0 " + response_code.to_s + " " + Status[response_code] + "\n"
    end
  end

  class Header
    def initialize()
      @headers = {
        "Server" => "mimikyu",
        "Date" => Time.now.httpdate,
        "Connection" => "close",
        "Content-Length" => "0"
      }
    end

    def set(name, value)
      @headers[name] = value
    end

    def set_content_length(length)
      set("Content-Length", length)
    end

    def set_content_type(type)
      set("Content-Type", type)
    end

    def build()
      @headers.reduce("") { |header, (key, value)|
        if value.to_s == "" then
          next header
        end
        header << key.to_s + ": " + value.to_s + "\n"
      }
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

    def file(request)
      @file_path = File.join(Response::DOCUMENT_ROOT, request.uri)
      if !File.file?(@file_path)
        raise HttpError.new(404)
      end

      status_line = StatusLine.new.build(200)
      begin
        file = File.open(@file_path, 'r')
        header = Header.new
        header.set_content_length(file.size)
        header.set_content_type(Response::ext_to_mime(File.extname(@file_path)))
        header = header.build
        body = file.read
      ensure
        file.close
      end
      return status_line, header, body
    end

    def text(status_code, body)
      status_line = StatusLine.new.build(status_code)
      header = Header.new
      header.set_content_length(body.length)
      header.set_content_type("text/html")
      header = header.build
      return status_line, header, body
    end
  end
end
