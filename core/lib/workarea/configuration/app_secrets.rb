# frozen_string_literal: true

module Workarea
  module Configuration
    # Accessor for application credentials.
    #
    # Rails deprecated the legacy secrets API in favour of
    # +Rails.application.credentials+. Workarea should read secrets from
    # credentials only.
    #
    # Usage:
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

      # Bracket accessor. Returns the credentials value when present.
      def [](key)
        key = key.to_sym
        Rails.application.credentials[key]
      rescue NoMethodError
        nil
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

        Rails.application.credentials.respond_to?(:key?) &&
          Rails.application.credentials.key?(key)
      rescue NoMethodError
        false
      end
    end
  end
end
