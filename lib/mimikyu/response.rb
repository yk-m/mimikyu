require 'mimikyu'
require 'time'

module Mimikyu
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
    DOCUMENT_ROOT = File.join(Dir.pwd, "www/html")
    CGI_ROOT = File.join(Dir.pwd, "www/cgi-bin")
    SH_ROOT = File.join(Dir.pwd, "config/sh")

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
      file_path = File.join(Response::DOCUMENT_ROOT, request.uri)
      status_line = StatusLine.new.build(200)
      begin
        file = File.open(file_path, 'r')
        header = Header.new
        header.set_content_length(file.size)
        header.set_content_type(Response::ext_to_mime(File.extname(file_path)))
        header = header.build
        body = file.read
      rescue Errno::ENOENT => e
        raise HttpError.new(404)
      ensure
        file.close if !file.nil?
      end
      return status_line, header, body
    end

    def cgi(request)
      file_path = File.join(Response::CGI_ROOT, request.uri)
      type = File.extname(file_path).delete(".")
      sh_path = File.join(Response::SH_ROOT, type + ".sh")
      if !File.file?(file_path)
        raise HttpError.new(404)
      end
      if !File.file?(sh_path)
        raise HttpError.new(404)
      end
      cmd = "sh " + sh_path + " " + file_path
      result = `#{cmd}`
      result_code = `echo $?`.chomp
      result_code = 200 if result_code == "0"
      status_line = StatusLine.new.build(result_code)
      return status_line, result, ""
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
