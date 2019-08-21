require 'test_helper'

module Workarea
  module Storefront
    class EmailSignupsIntegrationTest < Workarea::IntegrationTest
      def test_saves_a_sign_up
        post storefront.email_signup_path,
          params: { email: 'bcrouse@workarea.com' }

        assert_redirected_to(storefront.root_path)
        assert(cookies[:email].present?)
        assert(flash[:success].present?)
        assert_equal(1, Email::Signup.where(email: 'bcrouse@workarea.com').count)
      end

      def test_handles_a_sign_up_failure
        post storefront.email_signup_path,
          params: { email: 'bcrouse@workarea' }

        assert_redirected_to(storefront.root_path)
        assert(cookies[:email].blank?)
        assert(flash[:error].present?)
        assert_equal(0, Email::Signup.count)
      end
    end
  end
end
