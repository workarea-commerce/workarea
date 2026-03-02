# frozen_string_literal: true

module Workarea
  module Configuration
    # Backward-compatible accessor for application secrets/credentials.
    #
    # Rails 7.x deprecates +Rails.application.secrets+ in favour of
    # +Rails.application.credentials+. This proxy prefers credentials when a
    # value is present, and transparently falls back to secrets so that
    # existing deployments continue to work without any changes.
    #
    # Usage (mirrors the Rails.application.secrets API):
    #
    #   Workarea::Configuration::AppSecrets[:smtp_settings]
    #   Workarea::Configuration::AppSecrets.instance[:smtp_settings]
    #
    # Dot-notation (e.g. +AppSecrets.instance.smtp_settings+) is supported for
    # zero-arg, no-block calls only.
    #
    class AppSecrets
      # Singleton — callers should use AppSecrets.instance rather than .new.
      def self.instance
        @instance ||= new
      end

      # Convenience wrapper so callers can use:
      #
      #   Workarea::Configuration::AppSecrets[:smtp_settings]
      #
      def self.[](key)
        instance[key]
      end

      # Bracket accessor. Returns the credentials value when present,
      # otherwise falls back to the secrets value.
      def [](key)
        key = key.to_sym
        cred = Rails.application.credentials[key]
        return cred unless cred.nil?

        secrets_fetch(key)
      end

      # Forwards dot-notation calls (e.g. .smtp_settings) to +[]+.
      #
      # Only supports zero-arg, no-block calls so we don't mask real bugs.
      def method_missing(name, *args, &block)
        return super unless args.empty? && block.nil?

        self[name]
      end

      # Only report known keys as supported for dot-notation.
      def respond_to_missing?(name, include_private = false)
        key_exists?(name) || super
      end

      private

      def key_exists?(key)
        key = key.to_sym

        (Rails.application.credentials.respond_to?(:key?) && Rails.application.credentials.key?(key)) ||
          (Rails.application.secrets.respond_to?(:key?) && Rails.application.secrets.key?(key))
      rescue NoMethodError
        false
      end

      def secrets_fetch(key)
        secrets = Rails.application.secrets
        return nil if secrets.nil?

        # Bracket access so Rails normalizes string/symbol keys.
        secrets[key]
      rescue NoMethodError
        nil
      end
    end
  end
end
