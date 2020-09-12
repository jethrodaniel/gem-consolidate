$:.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name          = "fib"
  s.version       = "0.0.0"
  s.authors       = ["Mark Delk"]
  s.email         = ["jethrodaniel@gmail.com"]
  s.summary       = "CLI to print fibonacci numbers"
  s.license       = "MIT"
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.files         = Dir.glob("lib/**/*.rb")
  s.test_files    = Dir.glob("spec/**/*.rb")
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "test_bench", "~> 1.2"
end
