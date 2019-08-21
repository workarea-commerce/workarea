require 'test_helper'

module Workarea
  module Storefront
    class LoginSystemTest < Workarea::SystemTest
      setup :set_user
      setup :set_product_one
      setup :set_product_two

      def set_user
        @user = create_user(email: 'existing-account@workarea.com', password: 'W3bl1nc!')
        @admin = create_user(
          email: 'admin@workarea.com',
          password: 'W3bl1nc!',
          admin: true
        )
      end

      def set_product_one
        @product_one = create_product(
          name: 'Integration Product 1',
          variants: [{ sku: 'SKU1', regular: 5.to_m }]
        )
      end

      def set_product_two
        @product_two = create_product(
          name: 'Integration Product 2',
          variants: [{ sku: 'SKU2', regular: 5.to_m }]
        )
      end

      def test_basic_login
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'existing-account@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        assert(page.has_content?('Success'))

        click_link t('workarea.storefront.users.logout')
        assert(page.has_content?('Success'))

        visit storefront.users_account_path
        assert_current_path(storefront.login_path)
      end

      def test_user_lock_outs
        visit storefront.login_path

        Workarea.config.allowed_login_attempts.times do
          within '#login_form' do
            fill_in 'email', with: 'existing-account@workarea.com'
            fill_in 'password', with: 'wrong_password'
            click_button t('workarea.storefront.users.login')
          end
        end

        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'existing-account@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        assert(page.has_no_content?('Success'))
      end

      def test_cart_merging
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'existing-account@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        visit storefront.product_path(@product_one)
        click_button t('workarea.storefront.products.add_to_cart')

        within '.ui-dialog' do
          assert(page.has_content?(@product_one.name))
        end

        click_link t('workarea.storefront.users.logout')

        visit storefront.product_path(@product_two)
        click_button t('workarea.storefront.products.add_to_cart')

        within '.ui-dialog' do
          assert(page.has_content?(@product_two.name))
        end

        visit storefront.login_path
        within '#login_form' do
          fill_in 'email', with: 'existing-account@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        visit storefront.cart_path
        assert(page.has_content?('Integration Product 1'))
        assert(page.has_content?('Integration Product 2'))
      end

      def test_password_changing
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'existing-account@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        visit storefront.change_password_path

        within '#change_password_form' do
          fill_in 'old_password', with: 'W3bl1nc!'
          fill_in 'password', with: 'N3w_passw0rd!'
          click_button t('workarea.storefront.users.change_password')
        end

        assert_current_path(storefront.users_account_path)

        click_link t('workarea.storefront.users.logout')

        within '#login_form' do
          fill_in 'email', with: 'existing-account@workarea.com'
          fill_in 'password', with: 'N3w_passw0rd!'
          click_button t('workarea.storefront.users.login')
        end

        assert_current_path(storefront.users_account_path)
      end

      def test_admin_toolbar
        visit storefront.login_path

        refute_selector('.admin-toolbar')

        within '#login_form' do
          fill_in 'email', with: 'admin@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button 'login'
        end

        visit storefront.product_path(@product_one)

        assert_selector('.admin-toolbar')
      end
    end
  end
end
