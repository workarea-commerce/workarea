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
  s.required_ruby_version = ['>= 2.7.0', '< 3.5.0']

  s.add_dependency 'bundler', '>= 1.8.0' # 1.8.0 added env variable for secrets
s.add_dependency 'rails', '>= 6.1', '< 7.2'
  s.add_dependency 'mongoid', '~> 7.4'   # loosened from ~> 7.4.0; mongoid 8 needed for Rails 7 (BLOCKER)
  s.add_dependency 'bcrypt', '~> 3.1'    # loosened from ~> 3.1.10
  s.add_dependency 'money-rails', '~> 1.13' # loosened from ~> 1.13.0
  s.add_dependency 'mongoid-audit_log', '>= 0.6.0'
  s.add_dependency 'mongoid-document_path', '~> 0.2'   # loosened from ~> 0.2.0
  s.add_dependency 'mongoid-tree', '~> 2.1'             # loosened from ~> 2.1.0
  s.add_dependency 'mongoid-sample', '~> 0.1'           # loosened from ~> 0.1.0
  s.add_dependency 'mongoid-encrypted', '~> 1.0'        # loosened from ~> 1.0.0
  s.add_dependency 'elasticsearch', '~> 5.0'            # loosened from ~> 5.0.1; v5 client still a blocker for ES 7+
  # Faraday 2 moved adapters into separate gems; elasticsearch-transport 5 +
  # Faraday 2 requires an explicit adapter gem. faraday-net_http 3.x expects a
  # modern Faraday 2.x, so we also declare a compatible Faraday floor.
  s.add_dependency 'faraday', '>= 2.2', '< 3'
  s.add_dependency 'faraday-net_http', '~> 3.0'
  s.add_dependency 'kaminari', '~> 1.2'                 # loosened from ~> 1.2.1
  s.add_dependency 'kaminari-mongoid', '~> 1.0'         # loosened from ~> 1.0.0
  s.add_dependency 'activemerchant', '~> 1.52'
  s.add_dependency 'dragonfly', '~> 1.4'
  s.add_dependency 'sidekiq', '~> 7.0'
  # sidekiq-cron 1.2.0 requires `sidekiq/util`, which no longer exists in Sidekiq 6.5+.
  # Use a newer 1.x line that is compatible with Sidekiq 7.
  s.add_dependency 'sidekiq-cron', '~> 1.12'
  s.add_dependency 'sidekiq-unique-jobs', '~> 8.0'
  s.add_dependency 'sidekiq-throttled', '~> 1.5'
  s.add_dependency 'geocoder', '~> 1.6'                 # loosened from ~> 1.6.3
  s.add_dependency 'redis-rack-cache', '~> 2.2'         # loosened from ~> 2.2.0
  s.add_dependency 'easymon', '~> 1.4'                  # loosened from ~> 1.4.0
  s.add_dependency 'image_optim', '~> 0.28'             # loosened from ~> 0.28.0
  s.add_dependency 'image_optim_pack', '~> 0.7'         # loosened from ~> 0.7.0
  s.add_dependency 'faker', '~> 2.15'                   # loosened from ~> 2.15.0
  s.add_dependency 'fastimage', '~> 2.2'                # loosened from ~> 2.2.0
  s.add_dependency 'rack-timeout', '~> 0.6'             # loosened from ~> 0.6.0
  s.add_dependency 'autoprefixer-rails', '9.8.5' # the newer version prints an obnoxious deprecation warning
  s.add_dependency 'sassc-rails', '~> 2.1'              # loosened from ~> 2.1.0
  s.add_dependency 'ruby-stemmer', '~> 3.0'             # loosened from ~> 3.0.0
  s.add_dependency 'sprockets-rails', '~> 3.2'          # loosened from ~> 3.2.0; sprockets 4 needed for Rails 7 (BLOCKER)
  s.add_dependency 'sprockets', '~> 3.7'                # loosened from ~> 3.7.2; sprockets 4 needed for Rails 7 (BLOCKER)
  s.add_dependency 'predictor', '~> 2.3'                # loosened from ~> 2.3.0
  s.add_dependency 'js-routes', '~> 1.4'                # loosened from ~> 1.4.0
  s.add_dependency 'mongoid-active_merchant', '~> 0.2'  # loosened from ~> 0.2.0
  s.add_dependency 'normalize-rails', '~> 8.0'          # loosened from ~> 8.0.1
  s.add_dependency 'featurejs_rails', '~> 1.0'          # loosened from ~> 1.0.1
  s.add_dependency 'webcomponentsjs-rails', '~> 0.7'    # loosened from ~> 0.7.12
  s.add_dependency 'strftime-rails', '~> 0.9'           # loosened from ~> 0.9.2
  s.add_dependency 'i18n-js', '~> 3.8'                  # loosened from ~> 3.8.0
  s.add_dependency 'local_time', '~> 2.1'               # loosened from ~> 2.1.0
  s.add_dependency 'lodash-rails', '~> 4.17'            # loosened from ~> 4.17.4
  s.add_dependency 'jquery-rails', '~> 4.4'             # loosened from ~> 4.4.0
  s.add_dependency 'jquery-ui-rails', '~> 6.0'          # loosened from ~> 6.0.1
  s.add_dependency 'tooltipster-rails', '~> 4.2'        # loosened from ~> 4.2.0
  s.add_dependency 'select2-rails', '~> 4.0'            # loosened from ~> 4.0.3
  s.add_dependency 'wysihtml-rails', '~> 0.6.0.beta2'   # pre-release pin kept
  s.add_dependency 'rack-attack', '~> 6.3'              # loosened from ~> 6.3.1
  s.add_dependency 'redcarpet', '~> 3.5'                # loosened from ~> 3.5.1, >= 3.5.1
  s.add_dependency 'jquery-livetype-rails', '~> 0.1'    # loosened from ~> 0.1.0 # TODO remove v4
  s.add_dependency 'jquery-unique-clone-rails', '~> 1.0' # loosened from ~> 1.0.0
  s.add_dependency 'avalanche-rails', '~> 1.2'          # loosened from ~> 1.2.0
  s.add_dependency 'inline_svg', '~> 1.7'               # loosened from ~> 1.7.0
  s.add_dependency 'haml', '~> 5.2'                     # loosened from ~> 5.2.0; haml 6 may need Rails 7 work (BLOCKER)
  s.add_dependency 'ejs', '~> 1.1'                      # loosened from ~> 1.1.1
  s.add_dependency 'jbuilder', '~> 2.10'                # loosened from ~> 2.10.0
  s.add_dependency 'tribute', '~> 3.6'                  # loosened from ~> 3.6.0.0
  s.add_dependency 'turbolinks', '~> 5.2'               # loosened from ~> 5.2.0
  s.add_dependency 'jquery-validation-rails', '~> 1.19' # loosened from ~> 1.19.0
  s.add_dependency 'minitest', '~> 5.14'                # loosened from ~> 5.14.0
  s.add_dependency 'countries', '~> 3.0'                # loosened from ~> 3.0.0
  s.add_dependency 'waypoints_rails', '~> 4.0'          # loosened from ~> 4.0.1
  s.add_dependency 'rails-decorators', '~> 1.0.0.pre'   # pre-release pin kept
  s.add_dependency 'icalendar', '~> 2.7'                # loosened from ~> 2.7.0
  s.add_dependency 'premailer-rails', '~> 1.11'         # loosened from ~> 1.11.0
  s.add_dependency 'json-streamer', '~> 2.1'            # loosened from ~> 2.1.0
  s.add_dependency 'spectrum-rails', '~> 1.8'           # loosened from ~> 1.8.0
  s.add_dependency 'dragonfly-s3_data_store', '~> 1.3'  # loosened from ~> 1.3.0
  s.add_dependency 'loofah', '~> 2.9.0'                 # NOTE: PR #708 (wa-new-036) updates to 2.25.0
  s.add_dependency 'referer-parser', '~> 0.3'           # loosened from ~> 0.3.0
  s.add_dependency 'serviceworker-rails', '~> 0.6'      # loosened from ~> 0.6.0
  s.add_dependency 'chartkick', '~> 3.4'                # loosened from ~> 3.4.0
  s.add_dependency 'browser', '~> 5.3'                  # loosened from ~> 5.3.0
  s.add_dependency 'puma', '>= 4.3.1'
  s.add_dependency 'rack' , '>= 2.1.4'
  s.add_dependency 'dragonfly_libvips', '~> 2.4'        # loosened from ~> 2.4.2
  s.add_dependency 'sitemap_generator', '~> 6.1'        # loosened from ~> 6.1.2
  s.add_dependency 'recaptcha', '~> 5.6'                # loosened from ~> 5.6.0

  # HACK for vendoring active_shipping
  s.add_dependency 'active_utils', '~> 3.3'             # loosened from ~> 3.3.1
  s.add_dependency 'measured', '>= 2.0'
end
