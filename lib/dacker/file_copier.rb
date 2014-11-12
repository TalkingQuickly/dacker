module Dacker
  class FileCopier
    def initialize(options={})
      @files = options[:config]["files"]
      @host = options[:config]["host"]
      @user = options[:config]["user"]
    end

    attr_accessor :files, :host, :user

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
          destination
        )
        log "copied ok"
      end
    end

    def ensure_dir(file)
      Net::SSH.start(host, user) do |ssh|
        ssh.exec "mkdir -p #{file.split("/")[0..-2].join("/")}"
      end
    end

    def log(message, color=:green)
      Logger.log("#{host}: #{message}", color)
    end
  end
end
