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

      def test_class_bracket_delegates_to_instance
        assert_nil AppSecrets[:totally_unknown_key_xyz]
      end

      def test_bracket_and_method_access_are_equivalent
        # Both access paths should return the same value (nil for unknown keys).
        assert_equal AppSecrets.instance[:unknown_key], AppSecrets.instance.unknown_key
      end

      def test_method_missing_does_not_mask_args_or_blocks
        assert_raises(NoMethodError) { AppSecrets.instance.unknown_key(1) }
        assert_raises(NoMethodError) { AppSecrets.instance.unknown_key { :block } }
      end

      def test_reads_from_credentials
        # Stub credentials to return a value for :test_key.
        creds_stub = OpenStruct.new(test_key: 'from_credentials')

        with_stubbed_rails_application(:credentials, creds_stub) do
          result = AppSecrets.instance[:test_key]
          assert_equal 'from_credentials', result
        end
      end

      def test_returns_nil_when_missing_from_credentials
        creds_stub = OpenStruct.new({})
        creds_stub.define_singleton_method(:[]) { |_key| nil }

        with_stubbed_rails_application(:credentials, creds_stub) do
          result = AppSecrets.instance[:missing_key]
          assert_nil result
        end
      end

      def test_respond_to_missing_is_conservative
        refute AppSecrets.instance.respond_to?(:any_method_name)

        creds_stub = OpenStruct.new(test_key: 'from_credentials')
        creds_stub.define_singleton_method(:[]) { |key| key == :test_key ? 'from_credentials' : nil }
        creds_stub.define_singleton_method(:key?) { |key| key == :test_key }

        with_stubbed_rails_application(:credentials, creds_stub) do
          assert AppSecrets.instance.respond_to?(:test_key)
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
    end
  end
end
