require 'net/ssh'
require 'net/ssh/gateway'

module Dacker
  class Host
    def initialize(options={})
      @host = options[:host]
      @port = options[:port] || 2375
      @destport = options[:destport] || (port + 1)
      @username = options[:username] || 'deploy'
      forward_port!
    end

    attr_accessor :host, :port, :destport, :username

    def containers(options)
      ::Docker::Container.all(options, docker)
    end

    def info
      ::Docker.info(docker)
    end

    def docker
      @docker ||= Docker::Connection.new(
        "tcp://127.0.0.1:#{destport}",
        {}
      )
    end

    def gateway
      @gateway ||= Net::SSH::Gateway.new(host, username)
    end

    def forward_port!
      gateway.open('127.0.0.1', port, destport)
    end

    def close_port!
      gateway.shutdown!
    end
  end
end
