require 'httpserver'

module Httpserver
  Status = {
    200 => "OK",
    400 => "Bad Request",
    404 => "Not Found",
    405 => "Method Not Allowed",
    500 => "Internal Server Error"
  }

  class HttpError < StandardError
    attr_reader :code, :message
    def initialize(code)
      @code = code
      @message = Status[code]
    end
  end
end
