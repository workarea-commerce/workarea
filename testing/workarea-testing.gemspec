require File.expand_path('../../core/lib/workarea/version', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "workarea-testing"
  s.version     = Workarea::VERSION::STRING
  s.authors     = ["Ben Crouse"]
  s.email       = ["bcrouse@workarea.com"]
  s.homepage    = "http://www.workarea.com"
  s.license     = 'Business Software License'
  s.summary     = "Testing tools for the Workarea Commerce Platform"
  s.description = "Provides tooling for writing tests for the Workarea Commerce Platform."

  s.require_paths = %w(lib)
  s.files = `git ls-files`.split("\n")

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea-core', Workarea::VERSION::STRING
  s.add_dependency 'capybara', '~> 3.18'
  s.add_dependency 'webmock', '~> 3.5.0'
  s.add_dependency 'vcr', '~> 2.9.0'
  s.add_dependency 'launchy', '~> 2.4.3'
  s.add_dependency 'teaspoon', '~> 1.2.0'
  s.add_dependency 'teaspoon-mocha', '~> 2.3.3'
  s.add_dependency 'mocha', '~> 1.3.0'
  s.add_dependency 'selenium-webdriver', '~> 3.142'
  s.add_dependency 'webdrivers', '~> 4.0'
  s.add_dependency 'capybara-chromedriver-logger', '~> 0.2.1'
  s.add_dependency 'minitest-retry', '~> 0.1.5'
end
