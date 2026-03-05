require 'test_helper'

module Workarea
  module Configuration
    class SidekiqTest < TestCase
      # ---------------------------------------------------------------------------
      # SIDEKIQ_DEFAULTS resolution
      # ---------------------------------------------------------------------------

      def test_sidekiq_defaults_is_a_hash_with_concurrency_and_timeout
        defaults = Configuration::Sidekiq::SIDEKIQ_DEFAULTS
        assert_kind_of Hash, defaults
        assert(defaults.key?(:concurrency) || defaults.key?('concurrency'),
               'SIDEKIQ_DEFAULTS must contain a concurrency key')
        assert(defaults.key?(:timeout) || defaults.key?('timeout'),
               'SIDEKIQ_DEFAULTS must contain a timeout key')
      end

      # ---------------------------------------------------------------------------
      # concurrency
      # ---------------------------------------------------------------------------

      def test_concurrency_returns_integer_from_sidekiq_defaults_when_env_absent
        ENV.delete('WORKAREA_SIDEKIQ_CONCURRENCY')
        result = Configuration::Sidekiq.concurrency
        assert_kind_of Integer, result
        assert result > 0, 'concurrency should be a positive integer'
      end

      def test_concurrency_is_overridden_by_env_var
        ENV['WORKAREA_SIDEKIQ_CONCURRENCY'] = '42'
        assert_equal 42, Configuration::Sidekiq.concurrency
      ensure
        ENV.delete('WORKAREA_SIDEKIQ_CONCURRENCY')
      end

      def test_concurrency_env_var_is_coerced_to_integer
        ENV['WORKAREA_SIDEKIQ_CONCURRENCY'] = '7'
        assert_equal 7, Configuration::Sidekiq.concurrency
      ensure
        ENV.delete('WORKAREA_SIDEKIQ_CONCURRENCY')
      end

      # ---------------------------------------------------------------------------
      # timeout
      # ---------------------------------------------------------------------------

      def test_timeout_returns_integer_from_sidekiq_defaults_when_env_absent
        ENV.delete('WORKAREA_SIDEKIQ_TIMEOUT')
        ENV.delete('WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT')
        result = Configuration::Sidekiq.timeout
        assert_kind_of Integer, result
        assert result > 0, 'timeout should be a positive integer'
      end

      def test_timeout_is_overridden_by_env_var
        ENV['WORKAREA_SIDEKIQ_TIMEOUT'] = '99'
        assert_equal 99, Configuration::Sidekiq.timeout
      ensure
        ENV.delete('WORKAREA_SIDEKIQ_TIMEOUT')
      end

      def test_timeout_legacy_env_var_is_used_when_primary_absent
        ENV.delete('WORKAREA_SIDEKIQ_TIMEOUT')
        ENV['WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT'] = '55'
        assert_equal 55, Configuration::Sidekiq.timeout
      ensure
        ENV.delete('WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT')
      end

      def test_timeout_primary_env_var_takes_precedence_over_legacy
        ENV['WORKAREA_SIDEKIQ_TIMEOUT'] = '30'
        ENV['WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT'] = '55'
        assert_equal 30, Configuration::Sidekiq.timeout
      ensure
        ENV.delete('WORKAREA_SIDEKIQ_TIMEOUT')
        ENV.delete('WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT')
      end

      # ---------------------------------------------------------------------------
      # SIDEKIQ_DEFAULTS fallback value sanity
      # ---------------------------------------------------------------------------

      def test_sidekiq_defaults_concurrency_matches_resolved_value_when_no_env
        ENV.delete('WORKAREA_SIDEKIQ_CONCURRENCY')
        defaults = Configuration::Sidekiq::SIDEKIQ_DEFAULTS
        expected = (defaults[:concurrency] || defaults['concurrency']).to_i
        assert_equal expected, Configuration::Sidekiq.concurrency
      end

      def test_sidekiq_defaults_timeout_matches_resolved_value_when_no_env
        ENV.delete('WORKAREA_SIDEKIQ_TIMEOUT')
        ENV.delete('WORKAREA_SIDEKIQ_DEFAULT_TIMEOUT')
        defaults = Configuration::Sidekiq::SIDEKIQ_DEFAULTS
        expected = (defaults[:timeout] || defaults['timeout']).to_i
        assert_equal expected, Configuration::Sidekiq.timeout
      end

      # ---------------------------------------------------------------------------
      # ActiveJob adapter compatibility
      # ---------------------------------------------------------------------------

      def test_configure_plugins_does_not_override_test_adapter
        original_adapter = ActiveJob::Base.queue_adapter
        ActiveJob::Base.queue_adapter = :test

        Workarea::Configuration::Sidekiq.configure_plugins!

        assert_equal 'test', ActiveJob::Base.queue_adapter_name.to_s
      ensure
        ActiveJob::Base.queue_adapter = original_adapter
      end
    end
  end
end
