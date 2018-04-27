require 'httpserver'
require 'socket'

module Httpserver
  class Server
    def listen(host, port)
      Socket.tcp_server_loop(host, port) { |client, address|
        begin
          p client.gets

          client.puts "HTTP/1.0 200 OK"
          client.puts "Content-Type: text/html"
          client.puts "Content-Length: 6"
          client.puts ""
          client.puts "hello!"
        ensure
          client.close
        end
      }
    end
  end
end
