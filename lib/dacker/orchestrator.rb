module Dacker
  class Orchestrator
    def initialize(options={})
      @dackerfile_path = options[:dackerfile] || 'Dacerfile.yml'
      @env = options[:env]
      @dacker = options[:dacker] || dackerfile
      log "No configuration found for environment: #{env}", :red
    end

    attr_accessor :dacker, :dackerfile_path, :env

    def deploy!(filter=nil)
      filtered_containers(filter).each do |lf|
        ContainerDeployer.new(
          definition: lf[1]
        ).deploy!
      end if dacker
    end

    def filtered_containers(filter)
      if filter
        containers.select {|k| filter.include? k[0]}
      else
        containers
      end
    end

    def containers
      dacker.sort_by{|k,v| v["deploy"]["order"]}
    end

    def dackerfile
      @dackerfile ||= FileLoader.new(
        path: dackerfile_path,
        env: env
      ).content
    end

    def log(message, color=:green)
      Logger.log("#{message}", color)
    end
  end
end
