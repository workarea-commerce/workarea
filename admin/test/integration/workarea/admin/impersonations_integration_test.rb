require 'test_helper'

module Workarea
  module Admin
    class ImpersonationsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest
      setup :set_user
      setup :login_admin_user

      def set_user
        @user = create_user
      end

      def login_admin_user
        admin_user.update!(password: 'W3bl1nc!')

        post storefront.login_path,
          params: { email: admin_user.email, password: 'W3bl1nc!' }
      end

      def test_can_create_an_impersonation
        previous_user_id = session[:user_id]

        post admin.impersonations_path, params: { user_id: @user.id }

        assert(response.redirect?)
        assert_equal(@user.id.to_s, session[:user_id])
        assert_equal(previous_user_id, session[:admin_id])
      end

      def test_does_not_allow_impersonating_another_admin
        @user.update_attributes!(admin: true)

        assert_raises Admin::InvalidImpersonation do
          post admin.impersonations_path, params: { user_id: @user.id }
        end
      end

      def test_logs_the_impersonation_info_with_the_user
        previous_user_id = session[:user_id]
        post admin.impersonations_path, params: { user_id: @user.id }
        @user.reload

        assert_equal(previous_user_id, @user.last_impersonated_by_id)
        assert(@user.last_impersonated_at.present?)
      end

      def test_can_destroy_an_impersonation
        previous_user_id = session[:user_id]

        post admin.impersonations_path, params: { user_id: @user.id }
        delete admin.impersonations_path
        assert_equal(previous_user_id, session[:user_id])
        assert(session[:admin_id].blank?)

        post admin.impersonations_path, params: { user_id: @user.id }
        delete admin.impersonations_path
        assert_equal(previous_user_id, session[:user_id])
        assert(session[:admin_id].blank?)
      end

      def test_redirection_after_destroy
        post admin.impersonations_path, params: { user_id: @user.id }
        delete admin.impersonations_path
        assert_redirected_to(admin.user_path(@user.id))

        post admin.impersonations_path, params: { user_id: @user.id }
        delete admin.impersonations_path(return_to: '/foo')
        assert_redirected_to('/foo')

        post admin.impersonations_path, params: { user_id: @user.id }
        delete admin.impersonations_path(return_to: '/foo'),
          headers: { 'HTTP_REFERER' => admin.catalog_products_path }
        assert_redirected_to('/foo')

        post admin.impersonations_path, params: { user_id: @user.id }
        delete admin.impersonations_path,
          headers: { 'HTTP_REFERER' => admin.catalog_products_url(host: 'foo.com') }
        assert_redirected_to(admin.catalog_products_path)
      end
    end
  end
end
