require 'yaml'

module Dacker
  class FileLoader
    def initialize(options={})
      @path = options[:path] || "Latfile.yml"
    end

    attr_accessor :path

    def content
      @content ||= YAML.load_file(path)
    end
  end
end
