require 'httpserver'
require 'thor'

module Httpserver
  class CLI < Thor
    option(:host, :type => :string, :default => "0.0.0.0")
    option(:port, :type => :numeric, :default => 8080)
    desc("listen [host] [port]", "")
    def echo
      server = Server.new
      server.echo(options[:host], options[:port])
    end
  end
end
