$LOAD_PATH.push File.expand_path("lib", __dir__)
require "gem/consolidate/version"

Gem::Specification.new do |s|
  s.name          = "gem-consolidate"
  s.version       = Gem::Consolidate::VERSION
  s.authors       = ["Mark Delk"]
  s.email         = ["jethrodaniel@gmail.com"]
  s.summary       = "Consolidate a gem into a single file"
  s.homepage      = "https://github.com/jethrodaniel/gem-consolidate"
  s.license       = "MIT"
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = s.homepage

  s.require_paths = ["lib"]
  s.files         = Dir["lib/**/*.rb"] + Dir["exe/*"]
  s.test_files    = Dir["test/**/*.rb"]
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.add_dependency "parser"

  %w[
    parser
    rake
    rubocop
    test_bench
    pry
    pry-byebug
  ].each { |lib| s.add_development_dependency(lib) }
end
