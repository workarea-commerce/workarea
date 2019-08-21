require File.expand_path('../../core/lib/workarea/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "workarea-admin"
  s.version     = Workarea::VERSION::STRING
  s.authors     = ["Ben Crouse"]
  s.email       = ["bcrouse@workarea.com"]
  s.homepage    = "http://www.workarea.com"
  s.license     = 'Business Software License'
  s.summary     = "Admin for the Workarea Commerce Platform"
  s.description = "Provides site administration functionality for the Workarea Commerce Platform."

  s.files = `git ls-files`.split("\n")

  s.add_dependency 'workarea-core', Workarea::VERSION::STRING
  s.add_dependency 'workarea-storefront', Workarea::VERSION::STRING
end
