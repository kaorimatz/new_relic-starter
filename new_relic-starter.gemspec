# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'new_relic/starter/version'

Gem::Specification.new do |spec|
  spec.name          = 'new_relic-starter'
  spec.version       = NewRelic::Starter::VERSION
  spec.authors       = ['Satoshi Matsumoto']
  spec.email         = ['kaorimatz@gmail.com']

  spec.summary       = 'Start the New Relic agent in a running process.'
  spec.description   = <<-DESCRIPTION
  A library that provides a way to start the New Relic agent in a running
  process.
  DESCRIPTION
  spec.homepage      = 'https://github.com/kaorimatz/new_relic-starter'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z LICENSE.txt README.md ext lib`.split("\x0")
  end
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/new_relic_starter/extconf.rb']

  spec.add_runtime_dependency 'newrelic_rpm'
  spec.add_development_dependency 'benchmark_driver'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
