# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'superbolt/version'

Gem::Specification.new do |spec|
  spec.name          = "superbolt"
  spec.version       = Superbolt::VERSION
  spec.authors       = ["socialchorus"]
  spec.email         = ["developers@socialchorus.com"]
  spec.description   = %q{Superbolt is comprised of a standalone app, and a queue-like queue for sending messages between services and applications.}
  spec.summary       = %q{Superbolt is a gem that makes SOA intra-app communication easy, via RabbitMQ}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "amqp"
  spec.add_dependency "bunny"
  spec.add_dependency 'eventmachine'
  spec.add_dependency 'airbrake'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "= 2.14.1"
end
