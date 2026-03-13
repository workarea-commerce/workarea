source 'https://rubygems.org'

gemspec

gem 'workarea-core', path: 'core'
gem 'workarea-admin', path: 'admin'
gem 'workarea-storefront', path: 'storefront'
gem 'workarea-testing', path: 'testing'
gem 'listen'
gem 'bundler-audit'
gem 'brakeman'
gem 'rubocop'
gem 'rails-decorators', git: 'https://github.com/workarea-commerce/rails-decorators.git', branch: 'master'
gem 'teaspoon'

# redis-rb 5.x removed the `scheme:` connection option (handled in
# Configuration::Redis#to_h). Allow both 4.x and 5.x.
gem 'redis', '>= 4.8', '< 6'

# Ruby 3.4 stdlib-to-gem migrations: these were bundled in stdlib through 3.3
# but must be declared explicitly in Ruby 3.4+. activesupport 6.1 and other
# gems in the dependency tree require these but do not declare them explicitly.
# Required by: activesupport 6.1 (notifications/fanout.rb), workarea-core (csv import/export)
gem 'mutex_m'  # activesupport 6.1 notifications/fanout
gem 'csv'      # workarea-core lib/workarea/core.rb
gem 'drb'      # activesupport 6.1 testing/parallelization
gem 'logger'   # various gems
gem 'ostruct'  # various gems
