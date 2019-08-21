module Workarea
  module Storefront
    class EmailSignupsViewModel < ApplicationViewModel
      include DisplayContent

      def title
        browser_title.presence ||
          ::I18n.t('workarea.storefront.users.sign_up_for_email')
      end

      private

      def content_lookup
        'email_signup'
      end
    end
  end
end
