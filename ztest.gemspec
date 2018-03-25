# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ztest/version'

Gem::Specification.new do |spec|
  spec.name          = 'ztest'
  spec.version       = Ztest::VERSION
  spec.authors       = ['Matt Camuto']
  spec.email         = ['mattcamuto@gmail.com']

  spec.summary       = %q{Test For Zendesk.}
  spec.description   = %q{Test For Zendesk.}
  spec.homepage      = 'http://www.example.com/test/for/zendesk'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.7.0'
  spec.add_development_dependency 'rspec-collection_matchers'

  spec.add_development_dependency 'tty-prompt'
  spec.add_development_dependency 'tty-table'
  spec.add_development_dependency 'tty-tree'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'oj'
  spec.add_development_dependency 'pry'




end
