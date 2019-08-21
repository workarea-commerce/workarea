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
            Sidekiq::CallbacksWorker.workers.reduce({}) do |memo, worker|
              memo[worker] = [worker.enabled?, worker.inlined?]
              memo
            end

          Sidekiq::Testing.inline!
          Sidekiq::Callbacks.inline
        end

        teardown do
          Sidekiq::CallbacksWorker.workers.each do |worker|
            worker.enabled = @_worker_state[worker].first
            worker.inlined = @_worker_state[worker].second
          end
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

      def running_in_gem?
        warn <<~eos
          DEPRECATION WARNING: running_in_gem? is deprecated, use running_from_dummy_app? if
          you want to know if the test suite is running from a plugin or
          running_from_source? if you want to know if the currently executing test
          is defined in the current Rails project.
        eos
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

      def set_locales(available:, default:, current: nil)
        Rails.application.config.i18n.available_locales = I18n.available_locales = available
        Rails.application.config.i18n.default_locale = I18n.default_locale = default
        I18n.locale = current || default
      end

      def save_locales
        @current_rails_available_locales = Rails.application.config.i18n.available_locales
        @current_rails_default_locale = Rails.application.config.i18n.default_locale

        @current_i18n_available_locales = I18n.available_locales
        @current_i18n_default_locale = I18n.default_locale
        @current_i18n_locale = I18n.default_locale
      end

      def restore_locales
        Rails.application.config.i18n.available_locales = @current_rails_available_locales
        Rails.application.config.i18n.default_locale = @current_rails_default_locale

        I18n.available_locales = @current_i18n_available_locales
        I18n.default_locale = @current_i18n_default_locale
        I18n.locale = @current_i18n_locale
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
        Workarea.s3.directories.create(key: Configuration::S3.bucket)
      end

      def reset_s3
        Fog::Mock.reset
      end
    end

    extend Decoration
    extend RunnerLocation
    include Factories
    include Workers
    include RunnerLocation
    include Locales
    include S3

    setup do
      Mongoid.truncate!
      Workarea.redis.flushdb
      WebMock.disable_net_connect!(allow_localhost: true)
      Workarea.config.send_email = false
      Workarea.config.send_transactional_emails = false
      ActionMailer::Base.deliveries.clear

      Sidekiq::Testing.inline!
      Sidekiq::Callbacks.inline
      Sidekiq::Callbacks.disable
    end

    teardown do
      travel_back
    end
  end
end
