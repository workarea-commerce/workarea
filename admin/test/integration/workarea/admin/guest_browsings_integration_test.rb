require 'test_helper'

module Workarea
  module Admin
    class GuestBrowsingsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest
      setup :set_admin_user

      def set_admin_user
        admin_user.update!(password: 'W3bl1nc!')

        post storefront.login_path,
          params: { email: admin_user.email, password: 'W3bl1nc!' }
      end

      def test_start_guest_browsing
        previous_user_id = session[:user_id]

        post admin.guest_browsing_path

        assert(response.redirect?)
        assert_nil(session[:user_id])
        assert_equal(previous_user_id, session[:admin_id])
      end

      def test_ending_guest_browsing
        previous_user_id = session[:user_id]

        post admin.guest_browsing_path
        delete admin.guest_browsing_path

        assert(response.redirect?)
        assert_equal(previous_user_id, session[:user_id])
        assert(session[:admin_id].blank?)
      end
    end
  end
end
