# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "configurate"
  s.version     = "0.5.0"
  s.summary     = "Flexbile configuration system"
  s.description = "Configurate is a flexible configuration system that can "\
                  "read settings from multiple sources at the same time."
  s.authors     = ["Jonne Haß"]
  s.email       = "me@jhass.eu"
  s.homepage    = "http://jhass.github.io/configurate"
  s.license     = "MIT"

  s.files         = Dir["lib/**/*.rb"] + ["README.md", "Changelog.md", "LICENSE"]
  s.test_files    = Dir["spec/**/*.rb"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.3.0"

  s.add_development_dependency "rake",  ">= 10.0.3"
  s.add_development_dependency "rspec", ">= 3.0"
  s.add_development_dependency "toml-rb", ">= 2.0.1"
end
