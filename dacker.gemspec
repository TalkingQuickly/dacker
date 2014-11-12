# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dacker/version'

Gem::Specification.new do |spec|
  spec.name          = "dacker"
  spec.version       = Dacker::VERSION
  spec.authors       = ["Ben Dixon"]
  spec.email         = ["ben@talkingquickly.co.uk"]
  spec.summary       = %q{Multi host Docker Orchestration tool}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/TalkingQuickly/dacker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'docker-api', '~> 1.14.0'
  spec.add_dependency 'net-ssh', '~> 2.9.1'
  spec.add_dependency 'net-scp', '~> 1.2.1'
  spec.add_dependency 'net-ssh-gateway', '~> 1.2.0'
  spec.add_dependency 'colorize', '~> 0.7.3'
  spec.add_dependency 'thor', '~> 0.19.1'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
