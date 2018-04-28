require 'httpserver'
require 'socket'

module Httpserver
  class Server
    def echo(host, port)
      Socket.tcp_server_loop(host, port) { |client, address|
        begin
          IO.copy_stream(client, client)
        ensure
          client.close
        end
      }
    end
  end
end
