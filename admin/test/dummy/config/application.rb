require_relative 'boot'

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require 'workarea'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.load_defaults 6.0
    config.time_zone = 'Eastern Time (US & Canada)'
  end
end
