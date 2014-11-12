module Dacker
  class Installer
    def initialize
      @variant = "rails"
    end

    attr_accessor :variant

    def install
      begin
        existing_file("Dackerfile.yml")
        existing_folder("dacker")
        copy("Dackerfile.yml","Dackerfile.yml")
        copy_directory("dacker","./dacker")
      rescue Errno::ENOTEMPTY
        log "please remove your dacker.old dir then retry", :red
      end
    end

    def copy_directory(source, destination)
      log "copying #{source} to #{destination}"
      FileUtils.copy_entry(
        File.join(template_path, source),
        destination
      )
    end

    def copy(source, destination)
      log "copying #{source} to #{destination}"
      FileUtils.cp(
        File.join(template_path, source),
        destination
      )
    end

    def existing_file(file)
      if File.exist? file
        log "backing up: #{file} to #{file}.old"
        File.rename(file, "#{file}.old")
      end
    end

    def existing_folder(folder)
      log "backing up: #{folder} to #{folder}.old"
      if File.directory? folder
        File.rename(folder, "#{folder}.old")
      end
    end

    def template_path
      File.join(::Dacker.root, "templates", variant)
    end

    def log(message,color=:green)
      Logger.log("install: #{message}", color)
    end
  end
end
