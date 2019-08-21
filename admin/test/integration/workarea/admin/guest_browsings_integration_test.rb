require 'test_helper'

module Workarea
  module Admin
    class GuestBrowsingsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest
      setup :set_admin_user

      def set_admin_user
        super_admin = create_user(password: 'W3bl1nc!', super_admin: true)

        post storefront.login_path,
          params: { email: super_admin.email, password: 'W3bl1nc!' }
      end

      def request_cookies
        request.cookie_jar.signed
      end

      def response_cookies
        ActionDispatch::Cookies::CookieJar
          .build(request, response.cookies)
          .signed
      end

      def test_start_guest_browsing
        previous_user_id = request_cookies[:user_id]

        post admin.guest_browsing_path

        assert(response.redirect?)
        assert_nil(response_cookies['user_id'])
        assert(response_cookies['guest_browsing'].present?)
        assert_equal(previous_user_id, session['admin_id'].to_s)
      end

      def test_sets_a_timeout_on_guest_browsing
        post admin.guest_browsing_path

        cookies = response.to_a[1]['Set-Cookie'].split("\n")
        user_id_cookie = cookies.detect { |c| c.start_with?('guest_browsing') }

        assert_includes(user_id_cookie, 'expires')
      end

      def test_ending_guest_browsing
        previous_user_id = request_cookies[:user_id]

        post admin.guest_browsing_path

        assert(cookies['guest_browsing'].present?)

        delete admin.guest_browsing_path

        assert(response.redirect?)
        assert_equal(previous_user_id, response_cookies['user_id'])
        assert(session['admin_id'].blank?)
        assert(cookies['guest_browsing'].blank?)
      end
    end
  end
end
