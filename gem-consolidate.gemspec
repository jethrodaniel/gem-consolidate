$:.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name          = "gem-consolidate"
  s.version       = "0.1.0"
  s.authors       = ["Mark Delk"]
  s.email         = ["jethrodaniel@gmail.com"]
  s.summary       = "Consolidate a gem into a single file"
  s.homepage      = "https://github.com/jethrodaniel/gem-consolidate"
  s.license       = "MIT"
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = s.homepage

  s.files         = Dir.glob("lib/**/*.rb")
  s.test_files    = Dir.glob("spec/**/*.rb")
  s.require_paths = ["lib"]

  s.add_dependency "parser"

  s.add_development_dependency "rake"
end
