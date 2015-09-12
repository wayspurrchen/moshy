# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moshy/version'

Gem::Specification.new do |spec|
  spec.name        = "moshy"
  spec.version     = Moshy::VERSION
  spec.summary     = "datamoshing utility kit for common tasks with AVI files"
  spec.description = spec.summary
  spec.authors     = ["wayspurrchen"]
  spec.email       = 'wayspurrchen@gmail.com'
  spec.homepage    = 'https://github.com/wayspurrchen/moshy'
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "slop"
  spec.add_runtime_dependency "aviglitch"
  spec.add_runtime_dependency "av"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
