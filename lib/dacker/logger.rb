require 'colorize'

module Dacker
  class Logger
    def self.log(message, color)
      puts "  dacker: #{message}".colorize(color)
    end
  end
end
