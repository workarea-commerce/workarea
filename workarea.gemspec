require File.expand_path('../core/lib/workarea/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'workarea'
  s.version     = Workarea::VERSION::STRING
  s.authors     = ['Ben Crouse']
  s.email       = ['bcrouse@workarea.com']
  s.homepage    = 'http://www.workarea.com'
  s.license     = 'Business Software License'
  s.summary     = 'The Workarea Commerce Platform'
  s.description = 'Workarea is an enterprise-grade Ruby on Rails commerce platform.'

  s.files = Dir['README.md', 'CHANGELOG.md', '.rubocop.yml', 'docker-compose.yml']
  s.rdoc_options << '--exclude=docs'

  s.add_dependency 'workarea-core', Workarea::VERSION::STRING
  s.add_dependency 'workarea-storefront', Workarea::VERSION::STRING
  s.add_dependency 'workarea-admin', Workarea::VERSION::STRING
  s.add_dependency 'workarea-testing', Workarea::VERSION::STRING
end
