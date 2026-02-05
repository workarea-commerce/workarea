source 'https://rubygems.org'

gemspec

gem 'workarea-core', path: 'core'
gem 'workarea-admin', path: 'admin'
gem 'workarea-storefront', path: 'storefront'
gem 'workarea-testing', path: 'testing'
gem 'listen'
gem 'bundler-audit'
gem 'rubocop'
gem 'rails-decorators', git: 'https://github.com/workarea-commerce/rails-decorators.git', branch: 'master'
gem 'teaspoon'

# Workarea's Redis config passes `scheme:` which is supported by redis < 5.
# Newer redis (5.x) uses redis-client which does not accept `scheme:`.
gem 'redis', '~> 4.8'
