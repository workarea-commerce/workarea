module Workarea
  module Core
    class Engine < ::Rails::Engine
      extend Workarea::MountPoint

      isolate_namespace Workarea
      engine_name :workarea

      console do
        Mongoid::AuditLog.enable
        Mongoid::AuditLog.current_modifier = User.console
      end

      %w(app/queries app/seeds app/services app/view_models app/workers).each do |path|
        config.autoload_paths << "#{root}/#{path}"
      end

      config.before_configuration do
        #
        # Code here runs before the application's config/environments/#{current_environment}.rb
        #
        # So putting config here allows it to be overridden, which
        # is desirable for many types of config.
        #

        Configuration.setup_defaults

        Configuration::Sidekiq.load
        Configuration::CacheStore.load
        Configuration::AssetHost.load
        Configuration::ActionMailer.load
        Configuration::Logstasher.load
        Configuration::ErrorHandling.load
        Configuration::I18n.load
      end

      initializer 'workarea.core.image_optim', before: 'image_optim.initializer' do
        if Rails.application.config.assets.image_optim.blank?
          Rails.application.config.assets.image_optim = {
            pack: true,
            pngout: false,
            svgo: false
          }
        end
      end

      config.after_initialize do |app|
        # Do this after initialization so app initializers have a chance to run
        PingHomeBase.ping unless Rails.env.development? || Rails.env.test?

        if Rails.env.test?
          # This is here to help transition a poorly named configuration
          Configuration::HeadlessChrome.load

          # System tests can timeout without this, due to slow template resolution
          # if you have many plugins installed.
          ActionView::Resolver.caching = true
        end

        if app.assets.present?
          app.assets.context_class.instance_eval do
            include Workarea::Plugin::AssetAppendsHelper

            # Enable ActionView Helpers in the asset pipeline
            include ActionView::Helpers
            include InlineSvg::ActionView::Helpers
          end
        end

        Configuration::Mongoid.load unless Mongoid::Config.configured?
        Configuration::Dragonfly.load
        Configuration::LocalizedActiveFields.load

        Workarea::ScheduledJobs.clean

        if Rails.application.config.time_zone == 'UTC'
          warn <<~eos
**************************************************
⛔️ WARNING: Rails.application.config.time_zone is set to UTC, which you \
probably don't want.
As of Workarea 3.2, we use that value as the standard \
timezone for the admin side of the application.
We recommend setting this to the timezone of the retailer. Contact them to \
find their preference.
**************************************************
          eos
        end

        auto_redirect = 'Workarea::Search::StorefrontSearch::ProductAutoRedirect'
        if Workarea.config.storefront_search_middleware.include?(auto_redirect)
          warn <<~eos
DEPRECATION WARNING: #{auto_redirect} is deprecated and will be removed in Workarea 3.3. \
Remove it from Workarea.config.storefront_search_middleware.
          eos
        end

        if (!Rails.env.test? &&
            !Workarea.config.skip_service_connections &&
            Configuration::Mongoid.indexes_enforced?)
          warn <<~eos
**************************************************
⛔️ WARNING: MongoDB is configured with notablescan.

This means that MongoDB won't run queries that require a collection scan and will return an error.
Workarea turns this on for running tests to assert that queries have indexes, and turns it off at the end of the test run.
Since you're not running in the test environment and this is turned on, it might mean the test process was killed, preventing Workarea from turning it off.

To turn this off, start the mongo shell and run this command:
db.getSiblingDB("admin").runCommand( { setParameter: 1, notablescan: 0 } )
**************************************************
          eos
        end

        if !Rails.env.test? && !Rails.env.development? &&
             Dragonfly.app(:workarea).datastore.is_a?(Dragonfly::FileDataStore)

          warn <<~eos
**************************************************
⛔️ WARNING: Dragonfly is configured to use the filesystem.

This means all dragonfly assets (assets, product images, etc.) will be stored
locally and not accessible to all servers within your environment.

We recommend using S3 when running in a live environment by setting
WORKAREA_S3_REGION and WORKAREA_S3_BUCKET_NAME in your environment variables.
Workarea will automatically configure Dragonfly to use S3 if those values
are present.
**************************************************
          eos
        end
      end
    end
  end
end
