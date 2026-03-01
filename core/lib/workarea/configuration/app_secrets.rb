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
    #   Workarea::Configuration::AppSecrets.smtp_settings
    #   Workarea::Configuration::AppSecrets.send(:smtp_settings)
    #
    class AppSecrets
      # Singleton — callers should use AppSecrets.instance rather than .new.
      def self.instance
        @instance ||= new
      end

      # Bracket accessor.  Returns the credentials value when present,
      # otherwise falls back to the secrets value.
      def [](key)
        key = key.to_sym
        cred = Rails.application.credentials[key]
        return cred unless cred.nil?

        secrets_fetch(key)
      end

      # Forwards dot-notation calls (e.g. .smtp_settings) to +[]+.
      def method_missing(name, *_args)
        self[name]
      end

      def respond_to_missing?(_name, _include_private = false)
        true
      end

      # Convenience — allows AppSecrets.send(:some_key) to work the same way
      # as AppSecrets.some_key or AppSecrets[:some_key].
      alias_method :public_send, :method_missing

      private

      def secrets_fetch(key)
        secrets = Rails.application.secrets
        # secrets.respond_to?(:send) is always true but secrets[key] may be nil
        # while secrets.key_name returns nil rather than raising. Both paths are
        # equivalent for valid identifiers; bracket access is used so that
        # string/symbol normalisation is handled by Rails.
        secrets[key]
      rescue StandardError
        nil
      end
    end
  end
end
