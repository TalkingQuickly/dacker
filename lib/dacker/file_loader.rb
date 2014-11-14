require 'yaml'

module Dacker
  class FileLoader
    def initialize(options={})
      @path = options[:path] || "Dackerfile.yml"
      @env = options[:env] || "development"
    end

    attr_accessor :path, :env

    def content
      @content ||= YAML.load_file(path)[env]
    end
  end
end
