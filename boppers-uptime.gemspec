# frozen_string_literal: true

require "./lib/boppers/uptime/version"

Gem::Specification.new do |spec|
  spec.name          = "boppers-uptime"
  spec.version       = Boppers::Uptime::VERSION
  spec.authors       = ["Nando Vieira"]
  spec.email         = ["me@fnando.com"]
  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata = {"rubygems_mfa_required" => "true"}

  spec.summary       = "A bopper to check if your sites are online."
  spec.description   = spec.summary
  spec.homepage      = "https://rubygems.org/gems/boppers-uptime"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "boppers", ">= 0.0.11"
  spec.add_dependency "tzinfo"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest-utils"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry-meta"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop-fnando"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
end
