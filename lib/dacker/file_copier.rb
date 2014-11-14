require 'net/scp'

module Dacker
  class FileCopier
    def initialize(options={})
      @files = options[:config]["files"]
      @host = options[:config]["host"]
      @user = options[:config]["user"]
      @password = options[:config]["password"]
    end

    attr_accessor :files, :host, :user, :password

    def copy!
      return unless files
      files.each do |file|
        destination = file.split(":").first
        source = file.split(":").last
        if !File.exist? source
          log "local file #{source} does not exist, skipping", :red
          return
        end
        log "copying #{source} to #{destination}"
        ensure_dir(destination)
        Net::SCP.upload!(
          host,
          user,
          source,
          destination,
          ssh: ssh_options
        )
        log "copied ok"
      end
    end

    def ensure_dir(file)
      Net::SSH.start(host, user, ssh_options) do |ssh|
        ssh.exec "mkdir -p #{file.split("/")[0..-2].join("/")}"
      end
    end

    def ssh_options
      if password
        {
          password: password
        }
      else
        {}
      end
    end

    def log(message, color=:green)
      Logger.log("#{host}: #{message}", color)
    end
  end
end
