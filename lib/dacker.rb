require "dacker/version"
require "dacker/container"
require "dacker/container_deployer"
require "dacker/file_copier"
require "dacker/file_loader"
require "dacker/file_parser"
require "dacker/host"
require "dacker/logger"
require "dacker/orchestrator"
require "dacker/shell_runner"
require "dacker/installer"

Excon.defaults[:write_timeout] = 1000
Excon.defaults[:read_timeout] = 1000

module Dacker
  def self.root
    File.dirname __dir__
  end
end
