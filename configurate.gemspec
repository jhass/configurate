Gem::Specification.new do |s|
  s.name        = 'configurate'
  s.version     = '0.0.3.pre'
  s.summary     = "Flexbile configuration system"
  s.description = "Configurate is a flexible configuration system that can read settings from multiple sources at the same time."
  s.authors     = ["Jonne Haß"]
  s.email       = "me@mrzyx.de"
  s.homepage    = "http://mrzyx.github.com/configurate"
  s.license     = "MIT"

  s.files         = Dir["lib/**/*.rb"]
  s.test_files    = Dir["spec/**/*.rb"]
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.2'

  s.add_development_dependency 'rake',  '>= 10.0.3'
  s.add_development_dependency 'rspec', '>= 2.12.0'
end
