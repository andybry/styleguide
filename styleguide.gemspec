# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'styleguide/version'

Gem::Specification.new do |spec|
  spec.name          = "styleguide"
  spec.version       = Styleguide::VERSION
  spec.authors       = ["Andy Bryant"]
  spec.email         = ["ar.bryant@btinternet.com"]
  spec.description   = %q{A utility for writing, documenting and testing HTML, CSS and JavaScript}
  spec.summary       = %q{A utility to make it easier to write client side code}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ["styleguide"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
  spec.add_dependency "sprockets"
  spec.add_dependency "tilt"
  spec.add_dependency "rack"
  spec.add_dependency "thin"
  spec.add_dependency "sass"
  spec.add_dependency "jasmine"
  spec.add_dependency "guard"
  spec.add_dependency "guard-livereload"
  spec.add_dependency "guard-jasmine"
  spec.add_dependency "rack-livereload"
  spec.add_dependency "erubis"
  spec.add_dependency "eco"
  spec.add_dependency "ejs"
  spec.add_dependency "json"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 1.3"
end
