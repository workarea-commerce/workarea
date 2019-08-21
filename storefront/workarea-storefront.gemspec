require File.expand_path('../../core/lib/workarea/version', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "workarea-storefront"
  s.version     = Workarea::VERSION::STRING
  s.authors     = ["Ben Crouse"]
  s.email       = ["bcrouse@workarea.com"]
  s.homepage    = "http://www.workarea.com"
  s.license     = 'Business Software License'
  s.summary     = "Storefront for the Workarea Commerce Platform"
  s.description = "Provides user-facing ecommerce storefront functionality for the Workarea Commerce Platform."

  s.files = `git ls-files`.split("\n")
  s.add_dependency 'workarea-core', Workarea::VERSION::STRING
end
