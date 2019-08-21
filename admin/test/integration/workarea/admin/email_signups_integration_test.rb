require 'test_helper'

module Workarea
  module Admin
    class EmailSignupsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_destroy
        signup = create_email_signup

        delete admin.email_signup_path(signup)

        assert_redirected_to(admin.email_signups_path)
        assert_equal(0, Email::Signup.count)
      end
    end
  end
end
