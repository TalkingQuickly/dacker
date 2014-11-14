module Dacker
  class ShellRunner
    def initialize(options={})
      @definition ||= options[:definition]
    end

    attr_accessor :definition

    def cmd(cmd)
      system "ssh #{username}@#{host} '#{docker_cmd} #{cmd}'"
    end

    def docker_cmd
      "sudo docker run -i -t #{volumes} #{environment} #{name}"
    end

    def volumes
      if definition["volumes"]
        definition["volumes"].collect do |v|
          " -v #{v}"
        end.join(" ")
      else
        ""
      end
    end

    def environment
      if definition["environment"]
        definition["environment"].collect do |v|
          " -e #{v}"
        end.join(" ")
      else
        ""
      end
    end

    def name
      definition["deploy"]["image"] || definition["deploy"]["name"]
    end

    def username
      definition["deploy"]["user"]
    end

    def host
      definition["deploy"]["host"]
    end
  end
end
