require 'docker'

module Dacker
  class Container
    def initialize(options={})
      # @TODO: this is really an option parser
      @config = FileParser.new(
        config: options[:config]
      )
      @name = options[:name]
      @host = Host.new(
        host: options[:host],
        username: options[:username],
        password: options[:password]
      )
      @image = config.image
    end

    attr_accessor :config, :host, :image, :name

    def container(running=true)
      host.containers(all: !running).select do |c|
        c.info["Names"].include? "/#{name}"
      end.first
    end

    def signal(signal)
      log "signalling: #{signal}"
      container(true).kill(
        signal: signal
      ) if container(true)
    end

    def start
      log "starting container"
      container(false).start(
        {
          "Binds" => config.binds,
          "PortBindings" => config.port_bindings
        }
      ) if exists?
    end

    def build
      return nil unless config.build?
      log "building image from dir: #{config.build}"
      the_image ||= ::Docker::Image.build_from_dir(
        config.build,
        {},
        host.docker,
        {}
      ) do |output|
        #puts "   build:: #{output}"
      end
      @image = the_image.id
      the_image.tag(repo: name)
      log "build complete"
    end

    def pull
      log "pulling image: #{image}"
      ::Docker::Image.create(
        {
          fromImage: image
        },
        nil,
        host.docker
      )
      log "pull completed"
    end

    def create
      pull if !config.build?
      log "creating container"
      Docker::Container.create(
        {
          "Env" => config.env,
          "Image" => image,
          "ExposedPorts" => config.exposed_ports,
          "name" => name
        },
        host.docker
      )
      log "container created"
    end

    def stop
      container.stop if running?
    end

    def restart
      container.restart if exists?
    end

    def delete
      container(false).delete(force: true) if exists?
    end

    def exists?
      !container(false).nil?
    end

    def container_id
      container(false).info["id"]
    end

    def running?
      !container(true).nil?
    end

    def log(message, color=:green)
      Logger.log("#{name}: #{message}", color)
    end
  end
end
