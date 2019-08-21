require 'test_helper'

module Workarea
  module Storefront
    class EmailSignupSystemTest < Workarea::SystemTest
      def test_allows_email_signing_up
        visit storefront.email_signup_path

        within '#dialog_email_signup_form' do
          fill_in 'email', with: 'MMartyn@workarea.com'
          click_button t('workarea.storefront.users.join')
        end

        assert_current_path(storefront.email_signup_path)
        assert(page.has_content?('Success'))
      end
    end
  end
end
