module Workarea
  class TestCase < ActiveSupport::TestCase
    module Decoration
      mattr_accessor :loaded_decorators
      self.loaded_decorators = []

      def self.load_decorator(path)
        unless loaded_decorators.include?(path) || !File.file?(path)
          load path
          loaded_decorators << path
        end
      end

      def inherited(subclass)
        super

        absolute_path = caller[0].split(':').first
        # Don't try to find decorators for classes in the testing gem
        return if absolute_path.include?('workarea-testing') ||
                    absolute_path.include?('workarea/testing')

        relative_path = absolute_path.match(/(\/test.*)/).to_s
        decorator_relative = relative_path.gsub(
          '.rb',
          ".#{Rails::Decorators.extension}"
        )

        (Plugin.installed.map(&:root) + [Rails.root]).each do |root|
          decorator_location = [root, decorator_relative].join

          if File.exist?(decorator_location)
            TestCase::Decoration.load_decorator(decorator_location)
          end
        end
      end
    end

    module Workers
      extend ActiveSupport::Concern

      included do
        setup do
          @_worker_state =
            Sidekiq::Callbacks.workers.reduce({}) do |memo, worker|
              memo[worker] = [worker.enabled?, worker.inlined?]
              memo
            end

          Sidekiq::Testing.inline!
          Sidekiq::Callbacks.inline

          @_perform_enqueued_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
          @_perform_enqueued_at_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs

          ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
          ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
        end

        teardown do
          Sidekiq::Callbacks.workers.each do |worker|
            worker.enabled = @_worker_state[worker].first
            worker.inlined = @_worker_state[worker].second
          end

          ActiveJob::Base.queue_adapter.perform_enqueued_jobs = @_perform_enqueued_jobs
          ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = @_perform_enqueued_at_jobs
        end
      end
    end

    module SearchIndexing
      extend ActiveSupport::Concern

      included do
        setup do
          Workarea.config.auto_refresh_search = true
          WebMock.disable_net_connect!(allow_localhost: true)
          Workarea::Elasticsearch::Document.all.each(&:reset_indexes!)
          Workarea::Search::Storefront.ensure_dynamic_mappings
        end
      end
    end

    module Mail
      extend ActiveSupport::Concern

      included do
        setup do
          Workarea.config.send_email = true
          Workarea.config.send_transactional_emails = true
        end

        teardown do
          Workarea.config.send_email = false
          Workarea.config.send_transactional_emails = false
        end
      end
    end

    module RunnerLocation
      def running_from_source?
        return false unless running_in_dummy_app?

        calling_test = caller.detect do |path|
          /_test\.(rb|#{Rails::Decorators.extension})/.match?(path)
        end

        Rails.root.to_s.include?('test/dummy') &&
          Rails.root.to_s.split('/test/').first.eql?(calling_test.split('/test/').first)
      end

      # TODO remove in v3.6
      def running_in_gem?
        Workarea.deprecation.warn(
          <<~eos.squish
            running_in_gem? is deprecated, use running_from_dummy_app? if
            you want to know if the test suite is running from a plugin or
            running_from_source? if you want to know if the currently executing test
            is defined in the current Rails project.
          eos
        )
        running_from_source?
      end

      def running_in_dummy_app?
        return @running_in_dummy_app if defined?(@running_in_dummy_app)
        @running_in_dummy_app = Rails.root.to_s.include?('test/dummy')
      end
    end

    module Locales
      extend ActiveSupport::Concern

      included do
        setup :save_locales
        teardown :restore_locales

        delegate :t, to: :I18n
      end

      def set_locales(available:, default:, current: nil, fallbacks: nil)
        Rails.application.config.i18n.available_locales = I18n.available_locales = available
        Rails.application.config.i18n.default_locale = I18n.default_locale = default
        I18n.locale = current || default
        I18n.fallbacks = fallbacks if I18n.respond_to?(:fallbacks=)
      end

      def save_locales
        @current_rails_available_locales = Rails.application.config.i18n.available_locales
        @current_rails_default_locale = Rails.application.config.i18n.default_locale

        @current_i18n_available_locales = I18n.available_locales
        @current_i18n_default_locale = I18n.default_locale
        @current_i18n_locale = I18n.default_locale
        @current_i18n_fallbacks = I18n.try(:fallbacks)
      end

      def restore_locales
        Rails.application.config.i18n.available_locales = @current_rails_available_locales
        Rails.application.config.i18n.default_locale = @current_rails_default_locale

        I18n.available_locales = @current_i18n_available_locales
        I18n.default_locale = @current_i18n_default_locale
        I18n.locale = @current_i18n_locale
        I18n.fallbacks = @current_i18n_fallbacks if I18n.respond_to?(:fallbacks=)
      end
    end

    module S3
      extend ActiveSupport::Concern

      included do
        setup :mock_s3
        teardown :reset_s3
      end

      def mock_s3
        Fog.mock!
        Workarea.s3.directories.create(key: Workarea::Configuration::S3.bucket)
        Workarea.s3.stubs(:get_bucket_cors).returns(mock_s3_cors_response)
        Workarea.s3.stubs(:put_bucket_cors)
      end

      def reset_s3
        Fog::Mock.reset
      end

      def mock_s3_cors_response
        result = mock('Excon::Response')
        result.stubs(data: { body: { 'CORSConfiguration' => [] } })
        result
      end
    end

    module Configuration
      extend ActiveSupport::Concern

      included do
        setup :store_config_state
        teardown :reset_config_state
      end

      def store_config_state
        @original_config = Rails.configuration.workarea.deep_dup
      end

      def reset_config_state
        Rails.configuration.workarea = @original_config
      end
    end

    module Encryption
      extend ActiveSupport::Concern

      included do
        setup :ensure_encryption_key
        teardown :reset_encryption_key
      end

      def ensure_encryption_key(key: ActiveSupport::EncryptedFile.generate_key)
        env_key = Mongoid::Encrypted.configuration.env_key
        @original_key = ENV[env_key]
        ENV[env_key] ||= key
      end

      def reset_encryption_key
        ENV[Mongoid::Encrypted.configuration.env_key] = @original_key
      end
    end

    module Setup
      extend ActiveSupport::Concern
      include ActiveJob::TestHelper

      included do
        setup do
          Mongoid.truncate!
          Workarea.redis.flushdb
          WebMock.disable_net_connect!(allow_localhost: true)
          ActionMailer::Base.deliveries.clear
        end
      end
    end

    module Teardown
      extend ActiveSupport::Concern

      included do
        teardown do
          travel_back
          CurrentSegments.reset_segmented_content
        end
      end
    end

    module Geocoder
      extend ActiveSupport::Concern

      included do
        setup :save_geocoder_config
        teardown :restore_geocoder_config
      end

      def save_geocoder_config
        @original_geocoder_config = ::Geocoder.config.deep_dup
      end

      def restore_geocoder_config
        ::Geocoder.configure(@original_geocoder_config)
      end
    end

    extend Decoration
    extend RunnerLocation
    include Setup
    include Teardown
    include Configuration
    include Factories
    include Workers
    include RunnerLocation
    include Locales
    include S3
    include Encryption
    include Geocoder

    setup do
      Workarea.config.send_email = false
      Workarea.config.send_transactional_emails = false

      Sidekiq::Testing.inline!
      Sidekiq::Callbacks.inline
      Sidekiq::Callbacks.disable
    end
  end
end
