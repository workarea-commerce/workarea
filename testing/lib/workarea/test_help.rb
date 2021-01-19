require 'minitest/spec'
require 'sidekiq/testing/inline'
require 'sidekiq_unique_jobs/testing'
require 'mocha/mini_test'
require 'webmock/minitest'
require 'vcr'
require 'rails/test_unit/reporter'

if ENV['CI'].to_s =~ /true/
  require 'minitest/retry'
  Minitest::Retry.use!
end

allowed_hosts = ['127.0.0.1', 'localhost', 'chromedriver.storage.googleapis.com'] +
                 Workarea.elasticsearch.transport.hosts.map { |h| h[:host] } +
                 [Workarea.redis.connection[:host]] +
                  Mongoid::Config.clients.map { |k, v| v['hosts'] }.flatten

WebMock.disable_net_connect!(allow: allowed_hosts)

require 'workarea/testing/engine'
require 'workarea/testing/factory_configuration'
require 'workarea/testing/factories'
require 'workarea/testing/indexes'
require 'workarea/testing/cassette_persister'
require 'workarea/testing/decoration_reporter'

require 'workarea/test_case'
require 'workarea/integration_test'
require 'workarea/system_test'
require 'workarea/view_test'
require 'workarea/generator_test'
require 'workarea/performance_test'
require 'workarea/mailer_test'

require 'workarea/admin/integration_test'
require 'workarea/core/discount_condition_tests'
require 'workarea/core/featured_products_test'
require 'workarea/core/navigable_test'
require 'workarea/storefront/pagination_view_model_test'
require 'workarea/storefront/product_browsing_view_model_test'
require 'workarea/storefront/breakpoint_helpers'
require 'workarea/storefront/system_test'
require 'workarea/storefront/integration_test'
require 'workarea/storefront/catalog_customization_test_class'

Workarea::Factories.require_factories

Mongoid.purge!
Mongoid::Tasks::Database.create_indexes

Workarea::Testing::Indexes.enable_enforcing!
MiniTest.after_run { Workarea::Testing::Indexes.disable_enforcing! }

VCR.configure do |config|
  config.cassette_persisters[:workarea] = Workarea::Testing::CassettePersister
  config.default_cassette_options = { persist_with: :workarea }

  config.allow_http_connections_when_no_cassette = true
  config.hook_into(:webmock)
  config.ignore_hosts(*allowed_hosts)
end

Workarea::Plugin.installed.each do |plugin|
  Dir[plugin.root.join('test', 'support', '**', '*.rb')].each do |support_file|
    require support_file
  end
end

# The browser gem includes no user agent as a bot, and integration tests don't
# pass a user agent.
Browser::Bot.bot_exceptions << ''
#
# Set this to the lowest setting to improve performance creating passwords.
# Read more here: https://github.com/codahale/bcrypt-ruby#cost-factors
BCrypt::Engine.cost = 4
