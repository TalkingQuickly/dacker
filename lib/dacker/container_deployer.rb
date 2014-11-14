module Dacker
  class ContainerDeployer
    def initialize(options={})
      @definition = options[:definition]
    end

    attr_accessor :definition

    def deploy!
      log("starting deploy")
      copy_files
      if create_only? && !container.running?
        log("create only container is not running")
        container.build if !container.exists?
        container.create if !container.exists?
        container.start
      end
      if signal
        container.signal(signal)
      end
      if changes_container?
        check_stop
        config["container"].each do |cmd|
          container.send(cmd)
        end
      end
      check_running
      container.host.close_port!
    end

    def copy_files
      FileCopier.new(
        config: config
      ).copy!
    end

    def signal
      config["signal"]
    end

    def check_stop
      if !config["container"].include?("stop") && container.running?
        if signal
          log "container still running", :yellow
          log "waiting 5 seconds to see if it stops", :yellow
          sleep(5)
        end
        log "stop command not included and container still running", :red
        log "either use a signal to stop the containers running process or include stop", :red
      end
    end

    def check_running
      if container.running?
        log "container is running!"
      else
        log "container not running", :red
      end
    end

    def changes_container?
      !create_only?
    end

    def create_only?
      config["container"].nil? || config["container"].empty?
    end

    def config
      @deploy_config ||= definition["deploy"]
    end

    def container
      @container ||= Container.new(
        config: definition,
        name: definition["deploy"]["name"],
        host: definition["deploy"]["host"],
        username: definition["deploy"]["user"],
        password: definition["deploy"]["password"]
      )
    end

    def name
      @name ||= definition["deploy"]["name"]
    end

    def log(message, color=:green)
      Logger.log("#{name}: #{message}", color)
    end
  end
end
