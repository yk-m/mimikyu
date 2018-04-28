require 'httpserver'
require 'socket'
require 'time'

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

    def hello_world
      body = "Hello, world"
      listen_multi_thread { |client, address|
        client.puts "HTTP/1.1 200 OK"
        client.puts "Server: mimikyu"
        client.puts "Date: " + Time.now.httpdate
        client.puts "Content-Type: text/html"
        client.puts "Content-Length: " + body.length.to_s
        client.puts "Connection: keep-alive"
        client.puts ""
        client.puts body
      }
    end
  end
end
