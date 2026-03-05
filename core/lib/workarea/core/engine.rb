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

        # Redis 4.x defaults to returning a boolean from `sadd` for single-member
        # adds, but warns that Redis 5 will always return an Integer. Workarea
        # doesn't rely on boolean return values from `sadd`, so opt into the
        # Redis 5 behavior now to eliminate deprecation warnings.
        require 'redis'
        Redis.sadd_returns_boolean = false if Redis.respond_to?(:sadd_returns_boolean=)

        Configuration::Sidekiq.load
        Configuration::CacheStore.load
        Configuration::AssetHost.load
        Configuration::ActionMailer.load
        Configuration::ErrorHandling.load
        Configuration::I18n.load
        Configuration::ImageProcessing.load
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
          # Ensure system utilities (like `sysctl`) can be found when running tests.
          # Some CI environments have a restricted PATH that omits `/usr/sbin`,
          # which causes ImageOptim to raise Errno::ENOENT when it shells out to
          # `sysctl` to determine processor count.
          if File.exist?('/usr/sbin/sysctl')
            path = ENV['PATH'].to_s.split(File::PATH_SEPARATOR)
            ENV['PATH'] = ['/usr/sbin', *path].uniq.join(File::PATH_SEPARATOR)
          end

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
        Configuration::LocalizedFields.load
        Configuration::ContentBlocks.load

        Workarea::ScheduledJobs.clean
        Workarea::Warnings.check
        Configuration::Session.validate!
      end

      config.to_prepare do
        # For some reason, app/workers/workarea/bulk_index_products.rb doesn't
        # get autoloaded. Without this, admin actions like updating product
        # attributes raises a {NameError} "uninitialized constant BulkIndexProducts".
        require 'workarea/bulk_index_products'

        # Fixes a constant error raised in middleware (when doing segmentation)
        # No idea what the cause is. TODO revisit after Zeitwerk.
        require 'workarea/metrics/user'
      end
    end
  end
end
