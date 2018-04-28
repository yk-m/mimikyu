require 'httpserver'
require 'socket'

module Httpserver
  class Server
    def initialize(host, port)
      @host = host
      @port = port
    end

    def listen
      Socket.tcp_server_loop(@host, @port) { |client, address|
        begin
          yield client, address
        ensure
          client.close
        end
      }
    end

    def listen_multi_thread
      Socket.tcp_server_loop(@host, @port) { |client, address|
        Thread.new {
          begin
            yield client, address
          ensure
            client.close
          end
        }
      }
    end

    def echo
      listen { |client, address|
        IO.copy_stream(client, client)
      }
    end

    def echo_multi_thread
      listen_multi_thread { |client, address|
        IO.copy_stream(client, client)
      }
    end
  end
end