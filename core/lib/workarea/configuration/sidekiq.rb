module Workarea
  module Configuration
    module Sidekiq
      extend self

      # Sidekiq 7 uses Sidekiq::Config::DEFAULTS; Sidekiq 6 used Sidekiq::DEFAULTS.
      # Use whichever constant is available.
      SIDEKIQ_DEFAULTS = if defined?(::Sidekiq::Config::DEFAULTS)
        ::Sidekiq::Config::DEFAULTS
      elsif defined?(::Sidekiq::DEFAULTS)
        ::Sidekiq::DEFAULTS
      else
        { concurrency: 5, timeout: 25 }.freeze
      end

      def load
        require "#{Workarea::Core::Engine.root}/app/middleware/workarea/i18n_client_middleware"
        require "#{Workarea::Core::Engine.root}/app/middleware/workarea/i18n_server_middleware"
        require "#{Workarea::Core::Engine.root}/app/middleware/workarea/audit_log_client_middleware"
        require "#{Workarea::Core::Engine.root}/app/middleware/workarea/audit_log_server_middleware"
        require "#{Workarea::Core::Engine.root}/app/middleware/workarea/release_server_middleware"

        unless manually_configured?
          ::Sidekiq.configure_server do |config|
            # pidfile is a CLI-only concept in Sidekiq 7; skip it here.
            # In Sidekiq 6 it was configurable via the hash; we set it only
            # when the legacy constant is present so 6.x deployments still work.
            config[:pidfile] = pidfile if defined?(::Sidekiq::DEFAULTS)

            config.concurrency = concurrency
            config[:timeout]   = timeout
            config.queues      = queues
          end
        end

        configure_workarea!
      end

      def configure_workarea!
        ::Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add SidekiqUniqueJobs::Middleware::Server
            chain.add I18nServerMiddleware
            chain.add AuditLogServerMiddleware
            chain.add ReleaseServerMiddleware
          end

          config.client_middleware do |chain|
            chain.add SidekiqUniqueJobs::Middleware::Client
            chain.add I18nClientMiddleware
            chain.add AuditLogClientMiddleware
          end

          config.redis = {
            url: Configuration::Redis.persistent.to_url,
            size: pool_size,
            pool_timeout: pool_timeout
          }

          # From the sidekiq-unique-jobs README
          config.death_handlers << lambda do |job, ex|
            digest = job['lock_digest']
            SidekiqUniqueJobs::Digests.new.delete_by_digest(digest) if digest
          end
        end

        ::Sidekiq.configure_client do |config|
          config.client_middleware do |chain|
            chain.add SidekiqUniqueJobs::Middleware::Client
            chain.add Workarea::I18nClientMiddleware
            chain.add AuditLogClientMiddleware
          end

          config.redis = { url: Configuration::Redis.persistent.to_url }
        end
      end

      def configure_plugins!
        ActiveJob::Base.queue_adapter = :sidekiq

        # Sidekiq 7 enables strict argument checking by default, but Workarea
        # commonly passes BSON::ObjectId and other non-JSON-native types.
        ::Sidekiq.strict_args!(false) if ::Sidekiq.respond_to?(:strict_args!)

        if ::Sidekiq.const_defined?('Testing') && ::Sidekiq::Testing.inline?
          ::Sidekiq.configure_client do |config|
            config.client_middleware do |chain|
              # Avoid uniqueness locking in inline testing mode.
              chain.remove(SidekiqUniqueJobs::Middleware::Client) if defined?(SidekiqUniqueJobs::Middleware::Client)
            end
          end
        end

        require 'sidekiq/callbacks' unless defined?(::Sidekiq::Callbacks)
        ::Sidekiq::Callbacks.assert_valid_config!
        # sidekiq-throttled 1.x automatically installs its server middleware when
        # `sidekiq/throttled` is required; the old `.setup!` hook was removed.
      end

      def pidfile
        ENV['WORKAREA_SIDEKIQ_PIDFILE'].presence || './tmp/pids/sidekiq.pid'
      end

      def concurrency
        value = ENV['WORKAREA_SIDEKIQ_CONCURRENCY'].presence ||
          SIDEKIQ_DEFAULTS[:concurrency]

        value.to_i
      end

      def timeout
        value = ENV['WORKAREA_SIDEKIQ_TIMEOUT'].presence ||
          ENV['WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT'].presence || # legacy
          SIDEKIQ_DEFAULTS[:timeout]

        value.to_i
      end

      def queues
        ENV['WORKAREA_SIDEKIQ_QUEUES'].to_s.split(',').presence ||
          %w(releases high default low mailers)
      end

      def pool_size
        value = ENV['WORKAREA_SIDEKIQ_POOL_SIZE'].presence ||
          (concurrency + 5)

        value.to_i
      end

      def pool_timeout
        (ENV['WORKAREA_SIDEKIQ_POOL_TIMEOUT'].presence || 1).to_i
      end

      def manually_configured?
        %w[config/sidekiq.yml config/sidekiq.yml.erb].any? do |filename|
          File.exist?(Rails.root.join(filename))
        end
      end
    end
  end
end
