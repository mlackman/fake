Gem::Specification.new do |s|
  s.name        = "yafs"
  s.version     = "0.0.5"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Yet another fake http service for e2e tests"
  s.email       = "mika.lackman@gmail.com"
  s.description = "Fake http service, which is easy to use in tests"
  s.authors     = ['Mika Lackman']
  s.license     = "MIT"
  s.files         = Dir["README.md", "lib/**/*"]
  s.test_files    = Dir["spec/**/*.rb"]
  s.require_paths = ["lib"]
  s.add_dependency('rack')
end
