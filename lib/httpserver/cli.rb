require 'httpserver'
require 'thor'

module Httpserver
  class CLI < Thor
    option(:host, :type => :string, :default => "0.0.0.0")
    option(:port, :type => :numeric, :default => 8080)
    desc("echo [host] [port]", "up echo server")
    def echo
      Server.new(options[:host], options[:port]).echo
    end

    option(:host, :type => :string, :default => "0.0.0.0")
    option(:port, :type => :numeric, :default => 8080)
    desc("echo_multi_thread [host] [port]", "up multi thread echo server")
    def echo_multi_thread
      Server.new(options[:host], options[:port]).echo_multi_thread
    end
  end
end
