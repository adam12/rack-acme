# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rack/acme/version"

Gem::Specification.new do |spec|
  spec.name = "rack-acme"
  spec.version = Rack::Acme::VERSION
  spec.authors = ["Adam Daniels"]
  spec.email = ["adam@mediadrive.ca"]
  spec.summary = %q()
  spec.homepage = "https://github.com/adam12/rack-acme"
  spec.license = "MIT"

  spec.files = Dir["lib/**/*.rb"] + Dir["exe/*"]
  spec.add_dependency "rack"
  spec.add_dependency "acme-client"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rubygems-tasks", "~> 0.2"
end
