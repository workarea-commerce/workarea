# HACK to mimic the setup for rails test so we can inherit that functionality
# for rails workarea:test
#
if defined?(Rake.application) &&
    Rake.application.top_level_tasks.grep(/workarea:test/).any?
  ENV['RAILS_ENV'] ||= 'test'
  require 'rails/test_unit/railtie'
end

# HACK so the services tasks do not try to connect while loading workarea
if defined?(Rake.application) &&
    Rake.application.top_level_tasks.grep(/workarea:services/).any?
  ENV['WORKAREA_SKIP_SERVICES'] ||= 'true'
end

# HACK so the workarea:install generator does not require services to run
if ARGV.present? && ARGV.first == 'workarea:install'
  ENV['WORKAREA_SKIP_SERVICES'] ||= 'true'
end

 # HACK to allow vendoring active_shipping
 $:.unshift File.expand_path('../../../vendor/active_shipping/lib', __FILE__)

#
# Vendor Libraries
#
#
require 'mongoid'
require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/cron'
require 'sidekiq/cron/web'
require 'sidekiq-unique-jobs'
require 'sidekiq_unique_jobs/web'
require 'sidekiq/throttled'
require 'sidekiq/throttled/web'
require 'money-rails'
require 'kaminari'
require 'kaminari/mongoid'
require 'mongoid/audit_log'
require 'mongoid/document_path'
require 'mongoid/sample'
require 'elasticsearch'
require 'active_record/secure_token'
require 'active_merchant'
require 'mongoid/tree'
require 'dragonfly'
require 'net/ftp'
require 'net/sftp'
require 'geocoder'
require 'rack/timeout'
require 'easymon'
require 'mail'
require 'exifr/jpeg'
require 'image_optim'
require 'fastimage'
require 'action_view/template/resolver'
require 'sassc'
require 'sassc/rails'
require 'lingua/stemmer'
require 'autoprefixer-rails'
require 'predictor'
require 'js_routes'
require 'mongoid/active_merchant'
require 'normalize-rails'
require 'featurejs_rails'
require 'webcomponentsjs/rails'
require 'strftime/rails'
require 'i18n/js'
require 'local_time'
require 'lodash/rails'
require 'jquery/rails'
require 'jquery/ui/rails'
require 'tooltipster-rails'
require 'chart-js-rails'
require 'chart-horizontalbar-rails'
require 'select2-rails'
require 'wysihtml/rails'
require 'rack/attack'
require 'jquery-livetype-rails'
require 'active_shipping'
require 'jquery-unique-clone-rails'
require 'avalanche-rails'
require 'inline_svg'
require 'globalid'
require 'jquery-validation-rails'
require 'countries/global'
require 'countries/mongoid'
require 'waypoints_rails'
require 'rails/decorators'
require 'haml'
require 'ejs'
require 'jbuilder'
require 'redcarpet'
require 'turbolinks'
require 'csv'
require 'icalendar'
require 'icalendar/tzinfo'
require 'premailer/rails'
require 'rack/cache'
require 'rack/cache/key'
require 'json/streamer'
require 'spectrum-rails'
require 'referer-parser'
require 'dragonfly/s3_data_store'
require 'serviceworker-rails'
require 'chartkick'
require 'logstasher' if ENV['WORKAREA_LOGSTASH'] =~ /true/i

#
# Extensions
#
#
require 'workarea/ext/freedom_patches/float'
require 'workarea/ext/freedom_patches/money'
require 'workarea/ext/freedom_patches/string'
require 'workarea/ext/freedom_patches/bson'
require 'workarea/ext/freedom_patches/uri'
require 'workarea/ext/freedom_patches/action_view_cache_helper'
require 'workarea/ext/freedom_patches/action_view_conditional_url_helper'
require 'workarea/ext/freedom_patches/action_view_number_helper'
require 'workarea/ext/freedom_patches/dragonfly_attachment'
require 'workarea/ext/freedom_patches/mongoid_simple_tags'
require 'workarea/ext/freedom_patches/global_id'
require 'workarea/ext/freedom_patches/country'
require 'workarea/ext/freedom_patches/net_http_ssl_connection'
require 'workarea/ext/freedom_patches/dragonfly_job_fetch_url'
require 'workarea/ext/freedom_patches/dragonfly_callable_url_host'
require 'workarea/ext/mongoid/list_field'
require 'workarea/ext/mongoid/each_by'
require 'workarea/ext/mongoid/except'
require 'workarea/ext/mongoid/moped_bson'
require 'workarea/ext/mongoid/timestamps_timeless'
require 'workarea/ext/mongoid/error'
require 'workarea/ext/active_shipping/workarea'
require 'workarea/ext/mongoid/audit_log_entry.decorator'
require 'workarea/ext/mongoid/find_ordered'
require 'workarea/ext/sprockets/ruby_processor'
require 'workarea/ext/jbuilder/jbuilder_append_partials'

if Rails.env.development?
  require 'workarea/ext/freedom_patches/routes_reloader'
  require 'workarea/ext/freedom_patches/action_view_path_resolver'
end

module Workarea
  module Core
  end
end

#
# Application Libraries
#

require 'workarea/configuration'
require 'workarea/configuration/mongoid_client'
require 'workarea/configuration/mongoid'
require 'workarea/configuration/elasticsearch'
require 'workarea/configuration/redis'
require 'workarea/configuration/dragonfly'
require 'workarea/configuration/localized_active_fields'
require 'workarea/configuration/sidekiq'
require 'workarea/configuration/asset_host'
require 'workarea/configuration/s3'
require 'workarea/configuration/cache_store'
require 'workarea/configuration/action_mailer'
require 'workarea/configuration/logstasher'
require 'workarea/configuration/error_handling'
require 'workarea/configuration/i18n'
require 'workarea/configuration/headless_chrome'
require 'workarea/elasticsearch/index'
require 'workarea/elasticsearch/document'
require 'workarea/elasticsearch/query_cache'
require 'workarea/elasticsearch/serializer'
require 'workarea/constants'
require 'workarea/scheduler'
require 'workarea/i18n'
require 'workarea/validators/email_validator'
require 'workarea/validators/ip_address_validator'
require 'workarea/validators/password_validator'
require 'workarea/validators/parameter_validator'
require 'workarea/validators/url_validator'
require 'workarea/mount_point'
require 'workarea/plugin'
require 'workarea/plugin/asset_appends_helper'
require 'workarea/image_optim_processor'
require 'workarea/url_token'
require 'workarea/robots'
require 'workarea/paged_array'
require 'workarea/geolocation'
require 'workarea/autoexpire_cache_redis'
require 'workarea/swappable_list'
require 'workarea/asset_endpoints/base'
require 'workarea/asset_endpoints/product_images'
require 'workarea/asset_endpoints/product_placeholder_images'
require 'workarea/asset_endpoints/favicons'
require 'workarea/ping_home_base'
require 'workarea/monitoring/elasticsearch_check'
require 'workarea/monitoring/mongoid_check'
require 'workarea/monitoring/sidekiq_queue_size_check'
require 'workarea/monitoring/load_balancing_check'
require 'workarea/routes_constraints/super_admin'
require 'workarea/routes_constraints/redirect'
require 'workarea/svg_asset_finder'
require 'workarea/cache'
require 'workarea/scheduled_jobs'
require 'workarea/string_id'
require 'workarea/mail_interceptor'

#
# Core
#
#
require 'workarea/version'
require 'workarea/core/engine'

#
# Testing
#
#
require 'workarea/testing/engine' if Rails.env.test?
