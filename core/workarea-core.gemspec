require File.expand_path('../../core/lib/workarea/version', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "workarea-core"
  s.version     = Workarea::VERSION::STRING
  s.authors     = ["Ben Crouse"]
  s.email       = ["bcrouse@workarea.com"]
  s.homepage    = "http://www.workarea.com"
  s.license     = 'Business Software License'
  s.summary     = "Core of the Workarea Commerce Platform"
  s.description = "Provides application code, seed data, plugin infrastructure, and other core parts of the Workarea Commerce Platform."

  s.files = `git ls-files -- . ':!:data/product_images/*.jpg'`.split("\n")
  s.required_ruby_version = ['>= 2.4.0', '< 2.7.0']

  s.add_dependency 'bundler', '>= 1.8.0' # 1.8.0 added env variable for secrets
  s.add_dependency 'rails', '~> 5.2.0'
  s.add_dependency 'mongoid', '~> 6.4.0'
  s.add_dependency 'bcrypt', '~> 3.1.10'
  s.add_dependency 'money-rails', '~> 1.12.0'
  s.add_dependency 'mongoid-audit_log', '>= 0.5.0'
  s.add_dependency 'mongoid-document_path', '~> 0.1.0'
  s.add_dependency 'mongoid-tree', '~> 2.1.0'
  s.add_dependency 'mongoid-sample', '~> 0.1.0'
  s.add_dependency 'elasticsearch', '~> 5.0.1'
  s.add_dependency 'kaminari', '~> 0.17.0'
  s.add_dependency 'kaminari-mongoid', '~> 0.1.2'
  s.add_dependency 'activemerchant', '~> 1.52'
  s.add_dependency 'dragonfly', '~> 1.1.2'
  s.add_dependency 'sidekiq', '~> 5.2.2'
  s.add_dependency 'sidekiq-cron', '~> 0.6.3'
  s.add_dependency 'sidekiq-unique-jobs', '~> 6.0.6'
  s.add_dependency 'sidekiq-throttled', '~> 0.8.2'
  s.add_dependency 'geocoder', '~> 1.4.4'
  s.add_dependency 'redis-rails', '~> 5.0.0'
  s.add_dependency 'redis-rack-cache', '~> 2.2.0'
  s.add_dependency 'easymon', '~> 1.4.0'
  s.add_dependency 'image_optim', '~> 0.26.0'
  s.add_dependency 'image_optim_pack', '0.5.0.20171101'
  s.add_dependency 'faker', '~> 1.8.4'
  s.add_dependency 'fastimage', '~> 1.6.3'
  s.add_dependency 'faraday', '~> 0.15.4' # compatibility issue with 0.16
  s.add_dependency 'rack-timeout', '~> 0.1.1'
  s.add_dependency 'net-sftp', '~> 2.1.2'
  s.add_dependency 'autoprefixer-rails', '~> 6.5.1'
  s.add_dependency 'sassc-rails', '~> 1.3.0'
  s.add_dependency 'ruby-stemmer', '~> 0.9.6'
  s.add_dependency 'sprockets-rails', '~> 3.2.0'
  s.add_dependency 'sprockets', '~> 3.7.2'
  s.add_dependency 'predictor', '~> 2.3.0'
  s.add_dependency 'js-routes', '~> 1.3.0'
  s.add_dependency 'mongoid-active_merchant', '~> 0.2.0'
  s.add_dependency 'normalize-rails', '~> 4.1.1'
  s.add_dependency 'featurejs_rails', '~> 1.0.1'
  s.add_dependency 'webcomponentsjs-rails', '~> 0.7.12'
  s.add_dependency 'strftime-rails', '~> 0.9.2'
  s.add_dependency 'i18n-js', '~> 3.2.1'
  s.add_dependency 'local_time', '~> 1.0.3'
  s.add_dependency 'lodash-rails', '~> 4.17.4'
  s.add_dependency 'jquery-rails', '~> 4.3.1'
  s.add_dependency 'jquery-ui-rails', '~> 6.0.1'
  s.add_dependency 'tooltipster-rails', '~> 4.1.2'
  s.add_dependency 'chart-js-rails', '~> 0.0.9' # TODO remove v4
  s.add_dependency 'chart-horizontalbar-rails', '~> 1.0.4' # TODO remove v4
  s.add_dependency 'select2-rails', '~> 4.0.3'
  s.add_dependency 'wysihtml-rails', '~> 0.6.x'
  s.add_dependency 'rack-attack', '~> 5.0.1'
  s.add_dependency 'jquery-livetype-rails', '~> 0.1.0' # TODO remove v4
  s.add_dependency 'redcarpet', '~> 3.4.0'
  s.add_dependency 'jquery-unique-clone-rails', '~> 1.0.0'
  s.add_dependency 'avalanche-rails', '~> 1.2.0'
  s.add_dependency 'inline_svg', '~> 1.3.0'
  s.add_dependency 'haml', '~> 5.0.1'
  s.add_dependency 'ejs', '~> 1.1.1'
  s.add_dependency 'jbuilder', '~> 2.7.0'
  s.add_dependency 'turbolinks', '~> 5.0.1'
  s.add_dependency 'jquery-validation-rails', '~> 1.19.0'
  s.add_dependency 'minitest', '~> 5.10.3', '>= 5.10.1'
  s.add_dependency 'countries', '~> 2.1.4'
  s.add_dependency 'waypoints_rails', '~> 4.0.1'
  s.add_dependency 'rails-decorators', '~> 0.1.2'
  s.add_dependency 'icalendar', '~> 2.4.1'
  s.add_dependency 'premailer-rails', '~> 1.10.1'
  s.add_dependency 'json-streamer', '~> 2.0.1'
  s.add_dependency 'spectrum-rails', '~> 1.8.0'
  s.add_dependency 'rufus-scheduler', '< 3.5.0' # 3.5.0 breaks sidekiq-cron v0.6.x
  s.add_dependency 'dragonfly-s3_data_store', '~> 1.3.0'
  s.add_dependency 'loofah', '~> 2.3.1'
  s.add_dependency 'referer-parser', '~> 0.3.0'
  s.add_dependency 'serviceworker-rails', '~> 0.5.5'
  s.add_dependency 'logstasher', '~> 1.2.2'
  s.add_dependency 'chartkick', '~> 3.3.0'
  s.add_dependency 'puma', '~> 4.0'

  # HACK for vendoring active_shipping
  s.add_dependency 'active_utils', '~> 3.3.1'
  s.add_dependency 'measured', '>= 2.0'
end
