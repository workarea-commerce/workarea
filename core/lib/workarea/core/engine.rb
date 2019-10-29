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
        Configuration::ContentBlocks.load

        Workarea::ScheduledJobs.clean
        Workarea::Warnings.check
        Configuration::Session.validate!
      end
    end
  end
end
