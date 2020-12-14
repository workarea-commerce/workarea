module Workarea
  module Storefront
    module RecaptchaHelper
      def recaptcha(action:)
        return if recaptcha_type.none?

        if (recaptcha_type.v3_with_challenge? && challenge_recaptcha?) || recaptcha_type.v2?
          recaptcha_tags(site_key: Workarea.config.recaptcha_v2_site_key)
        elsif recaptcha_type.v3_with_challenge? || recaptcha_type.v3?
          recaptcha_v3(action: action, site_key: Workarea.config.recaptcha_v3_site_key)
        end
      end
    end
  end
end
