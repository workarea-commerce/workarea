require 'test_helper'

module Workarea
  module Configuration
    class AppSecretsTest < TestCase
      setup do
        # Reset the singleton so each test gets a fresh instance.
        AppSecrets.instance_variable_set(:@instance, nil)
      end

      teardown do
        AppSecrets.instance_variable_set(:@instance, nil)
      end

      def test_returns_nil_for_unknown_key
        assert_nil AppSecrets.instance[:totally_unknown_key_xyz]
      end

      def test_bracket_and_method_access_are_equivalent
        # Both access paths should return the same value (nil for unknown keys).
        assert_equal AppSecrets.instance[:unknown_key], AppSecrets.instance.unknown_key
      end

      def test_credentials_preferred_over_secrets
        # Stub credentials to return a value for :test_key.
        creds_stub = OpenStruct.new(test_key: 'from_credentials')

        with_stubbed_rails_application(:credentials, creds_stub) do
          result = AppSecrets.instance[:test_key]
          assert_equal 'from_credentials', result
        end
      end

      def test_falls_back_to_secrets_when_credentials_nil
        # Stub credentials to return nil, secrets to return a value.
        creds_stub = OpenStruct.new({})
        creds_stub.define_singleton_method(:[]) { |_key| nil }

        secrets_stub = OpenStruct.new(fallback_key: 'from_secrets')
        secrets_stub.define_singleton_method(:[]) { |key| key == :fallback_key ? 'from_secrets' : nil }

        with_stubbed_rails_application(:credentials, creds_stub) do
          with_stubbed_rails_application(:secrets, secrets_stub) do
            AppSecrets.instance_variable_set(:@instance, nil)
            result = AppSecrets.instance[:fallback_key]
            assert_equal 'from_secrets', result
          end
        end
      end

      private

      def with_stubbed_rails_application(method_name, value)
        singleton = Rails.application.singleton_class
        original_method_name = "__original_#{method_name}".to_sym

        singleton.alias_method(original_method_name, method_name)
        singleton.define_method(method_name) { value }

        yield
      ensure
        singleton.alias_method(method_name, original_method_name)
        singleton.remove_method(original_method_name)
      end

      def test_respond_to_missing
        assert AppSecrets.instance.respond_to?(:any_method_name)
      end
    end
  end
end
