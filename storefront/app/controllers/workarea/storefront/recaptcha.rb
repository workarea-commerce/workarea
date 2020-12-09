module Workarea
  module Storefront
    module Recaptcha
      extend ActiveSupport::Concern

      included do
        helper_method :recaptcha_type
        helper_method :challenge_recaptcha?
      end

      def recaptcha_type
        v3 = Workarea.config.recaptcha_v3_site_key.present? && Workarea.config.recaptcha_v3_secret_key.present?
        v2 = Workarea.config.recaptcha_v2_site_key.present? && Workarea.config.recaptcha_v2_secret_key.present?

        result = if v3 && v2
          'v3_with_challenge'
        elsif v3
          'v3'
        elsif v2
          'v2'
        else
          'none'
        end

        result.inquiry
      end

      def invalid_recaptcha?(action:)
        return false if recaptcha_type.none?

        valid = if recaptcha_type.v3_with_challenge?
          valid_v3_recaptcha?(action: action) || valid_v2_recaptcha?
        elsif recaptcha_type.v3?
          valid_v3_recaptcha?(action: action)
        elsif recaptcha_type.v2?
          valid_v2_recaptcha?
        end

        !valid
      end

      def valid_v3_recaptcha?(action:)
        verify_recaptcha(
          action: action,
          secret_key: Workarea.config.recaptcha_v3_secret_key,
          minimum_score: Workarea.config.recaptcha_v3_minimum_score
        )
      end

      def valid_v2_recaptcha?
        verify_recaptcha(secret_key: Workarea.config.recaptcha_v2_secret_key)
      end

      def challenge_recaptcha!
        @recaptcha_challenge = true if recaptcha_type.v3_with_challenge?
      end

      def challenge_recaptcha?
        !!@recaptcha_challenge
      end
    end
  end
end
