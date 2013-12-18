# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'overflow/version'

Gem::Specification.new do |spec|
  spec.name          = "overflow"
  spec.version       = Overflow::VERSION
  spec.author        = "ksss"
  spec.email         = "co000ri@gmail.com"
  spec.description   = %q{Overflow is a class to overflow calculated as C language in Ruby.}
  spec.summary       = %q{Overflow is a class to overflow calculated as C language in Ruby.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/overflow/extconf.rb"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ['~> 2.11']
  spec.add_development_dependency "rake-compiler", ["~> 0.8.3"]
  spec.add_development_dependency "limits"
end
