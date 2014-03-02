# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blockchain/version'

Gem::Specification.new do |spec|
  spec.name          = "blockchain"
  spec.version       = Blockchain::VERSION
  spec.authors       = ["Alex Skryl"]
  spec.email         = ["rut216@gmail.com"]
  spec.description   = %q{Perform common blockchain operations.}
  spec.summary       = %q{Perform common blockchain operations}
  spec.homepage      = "http://github.com/skryl/blockchain"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "activerecord", "3.2.14"
  spec.add_dependency "httparty"
  spec.add_dependency "mysql2"
  spec.add_dependency "buffered_logger"
end
