module Dacker
  class FileParser
    def initialize(options={})
      @config = options[:config]
    end

    attr_accessor :config

    def port_bindings
      out = {}
      config["ports"].each do |port|
        host = port.split(":")[0]
        container = port.split(":")[1]
        out["#{container}/tcp"] = [{"HostPort" => host}]
      end
      out
    end

    def binds
      config["volumes"]
    end

    def env
      config["environment"].join(" ") if config["environment"]
      config["environment"] || []
    end

    def exposed_ports
      out = {}
      config["ports"].each do |port|
        container = port.split(":")[1]
        out["#{container}/tcp"] = {}
      end
      out
    end

    def build
      config["build"]
    end

    def image
      config["image"]
    end

    def build?
      !build.nil?
    end
  end
end
