require 'test_helper'

module Workarea
  module Admin
    class ImpersonationsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest
      setup :set_user
      setup :set_super_user

      def set_user
        @user = create_user
      end

      def set_super_user
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

      def test_can_create_an_impersonation
        previous_user_id = request_cookies[:user_id]

        post admin.impersonations_path, params: { user_id: @user.id }

        assert(response.redirect?)
        refute_equal(previous_user_id, response_cookies['user_id'])
        assert_equal(previous_user_id, session['admin_id'].to_s)
      end

      def test_sets_a_timeout_on_an_impersonation
        post admin.impersonations_path, params: { user_id: @user.id }

        cookies = response.to_a[1]['Set-Cookie'].split("\n")
        user_id_cookie = cookies.detect { |c| c.start_with?('user_id') }

        assert_includes(user_id_cookie, 'expires')
      end

      def test_does_not_allow_impersonating_another_admin
        @user.update_attributes!(admin: true)

        assert_raises Admin::InvalidImpersonation do
          post admin.impersonations_path, params: { user_id: @user.id }
        end
      end

      def test_logs_the_impersonation_info_with_the_user
        previous_user_id = request_cookies[:user_id]
        post admin.impersonations_path, params: { user_id: @user.id }
        @user.reload

        assert_equal(previous_user_id.to_s, @user.last_impersonated_by_id)
        assert(@user.last_impersonated_at.present?)
      end

      def test_can_destroy_an_impersonation
        previous_user_id = request_cookies[:user_id]

        post admin.impersonations_path, params: { user_id: @user.id }
        delete admin.impersonations_path

        assert(response.redirect?)
        assert_equal(previous_user_id, response_cookies['user_id'])
        assert(session['admin_id'].blank?)
      end
    end
  end
end
