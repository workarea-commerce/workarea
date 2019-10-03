module Workarea
  module Configuration
    module Session
      class NoExpirationConfigured < StandardError; end
      extend self

      def cookie_store?
        return @cookie_store if defined?(@cookie_store)
        @cookie_store = Rails.application.config.session_store == ActionDispatch::Session::CookieStore
      end

      def key
        Rails.application.config.session_options[:key]
      end

      def ttl
        Rails.application.config.session_options[:expire_after]
      end

      def validate!
        if ttl.blank?
          raise(
            NoExpirationConfigured,
            <<~eos

              Problem:
                Workarea requires a session expiration to be set. We recommend 30 minutes.
              Solution:
                Add `expire_after: 30.minutes` to your session configuration in `config/initializers/session_store.rb`
            eos
          )
        end
      end
    end
  end
end
