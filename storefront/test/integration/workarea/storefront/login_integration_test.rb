require 'test_helper'

module Workarea
  module Storefront
    class LoginIntegrationTest < Workarea::IntegrationTest
      setup :set_user

      def set_user
        @user = create_user(
          email: 'existing-account@workarea.com',
          password: 'W3bl1nc!'
        )
      end

      def test_can_login_a_user
        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'W3bl1nc!'
          }

        assert_redirected_to(storefront.users_account_path)
        assert(session[:user_id].present?)

        @user.reload
        assert(@user.last_login_at.present?)
      end

      def test_does_not_login_when_not_matching_credentials
        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'foo'
          }

        assert(session[:user_id].blank?)

        @user.reload
        assert(@user.last_login_at.blank?)
      end

      def test_redirects_a_user_to_return_after_logging_in
        get storefront.edit_users_account_path

        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'W3bl1nc!'
          }

        assert_redirected_to(storefront.edit_users_account_path)
      end

      def test_redirects_to_the_admin_path_for_admins_by_deafult
        @user.update_attributes!(admin: true)

        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'W3bl1nc!'
          }

        assert_match(/admin/, response.location)
      end

      def test_locks_out_a_user_after_excessive_login_attempts
        Workarea.config.allowed_login_attempts.times do
          post storefront.login_path,
            params: {
              email: 'existing-account@workarea.com',
              password: 'wrong_password'
            }
        end

        @user.reload
        assert(@user.login_locked?)
      end

      def test_a_user_can_change_their_password
        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'W3bl1nc!'
          }

        patch storefront.change_password_path,
          params: {
            old_password: 'W3bl1nc!',
            password: 'New_Passw0rd!'
          }

        found_user = User.find_for_login(
          'existing-account@workarea.com',
          'New_Passw0rd!'
        )

        assert(found_user.present?)
      end

      def test_does_not_redirect_back_on_a_form_submission
        post storefront.users_addresses_path,
          params: {
            address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '12 N. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              country: 'US',
              postal_code: '19106',
              phone_number: '2159251800'
            }
          }

        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'W3bl1nc!'
          }

        assert(response.redirect?)
        assert(response.location.end_with?(storefront.users_account_path))
      end

      def test_logs_out_a_user
        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'W3bl1nc!'
          }

        product = create_product
        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 1
          }

        delete storefront.logout_path

        assert_redirected_to(storefront.login_path)
        assert(session[:user_id].blank?)

        get storefront.current_user_path(format: 'json')
        results = JSON.parse(response.body)
        assert_equal(0, results['cart_quantity'])
      end

      def test_it_doesnt_care_about_csrf_for_logout
        current_forgery_protection = ActionController::Base.allow_forgery_protection

        post storefront.login_path,
          params: {
            email: 'existing-account@workarea.com',
            password: 'W3bl1nc!'
          }

        ActionController::Base.allow_forgery_protection = true
        delete storefront.logout_path
        assert(response.headers['Set-Cookie'].present?)

      ensure
        ActionController::Base.allow_forgery_protection = current_forgery_protection
      end
    end
  end
end
