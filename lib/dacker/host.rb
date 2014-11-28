require 'net/ssh'
require 'net/ssh/gateway'

module Dacker
  class Host
    def initialize(options={})
      @host = options[:host]
      @port = options[:port] || 2375
      @username = options[:username] || 'deploy'
      @password = options[:password]
      forward_port!
      authenticate!
    end

    def authenticate!
      if (user=ENV['DOCKER_USERNAME']) && (password=ENV['DOCKER_PASSWORD']) && (email=ENV['DOCKER_EMAIL'])
        Docker.authenticate!(
          {
            'username' => user,
            'password' => password,
            'email' => email
          },
          docker
        )
      end
    end

    attr_accessor :host, :port, :username, :password, :destport

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
      @gateway ||= Net::SSH::Gateway.new(host, username, gateway_options)
    end

    def gateway_options
      if password
        {
          password: password
        }
      else
        {}
      end
    end

    def forward_port!
      @destport = gateway.open('127.0.0.1', port)
    end

    def close_port!
      gateway.shutdown!
    end
  end
end
