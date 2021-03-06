module Dacker
  class Installer
    def initialize
      @variant = "rails"
    end

    attr_accessor :variant

    def install
      begin
        existing_file("Dackerfile.yml")
        existing_file("Vagrantfile")
        existing_file("Dockerfile")
        existing_folder("dacker")
        copy("Dackerfile.yml","Dackerfile.yml")
        copy("Dockerfile","Dockerfile")
        copy("Vagrantfile", "Vagrantfile", false)
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

    def copy(source, destination, use_variant=true)
      log "copying #{source} to #{destination}"
      FileUtils.cp(
        File.join(template_path(use_variant), source),
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

    def template_path(use_variant=true)
      if use_variant
        File.join(::Dacker.root, "templates", variant)
      else
        File.join(::Dacker.root, "templates")
      end
    end

    def log(message,color=:green)
      Logger.log("install: #{message}", color)
    end
  end
end
