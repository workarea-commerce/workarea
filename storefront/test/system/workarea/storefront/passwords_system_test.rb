require 'test_helper'

module Workarea
  module Storefront
    class PasswordsSystemTest < Workarea::SystemTest
      setup :set_customer_email
      setup :set_admin_email
      setup :set_password
      setup :set_customer_user
      setup :set_admin_user

      def set_customer_email
        @customer_email = 'test@workarea.com'
      end

      def set_admin_email
        @admin_email = 'test-admin@workarea.com'
      end

      def set_password
        @password = 'P@ssw0rd!!'
      end

      def set_customer_user
        @customer_user = create_user(email: @customer_email, password: 'W3bl1nc!')
      end

      def set_admin_user
        create_user(
          email: @admin_email,
          password: 'W3bl1nc!',
          admin: true
        )
      end

      def test_customer_resetting_a_password
        visit storefront.forgot_password_path

        within '#forgot_password_form' do
          fill_in 'email', with: 'bogus@email.com'
          click_button t('workarea.storefront.forms.send')
        end
        assert(page.has_content?(t('workarea.storefront.flash_messages.password_reset_email_sent', email: 'bogus@email.com')))

        within '#forgot_password_form' do
          fill_in 'email', with: @customer_email
          click_button t('workarea.storefront.forms.send')
        end

        # User comes back from a link in an email
        token = User::PasswordReset.first.token
        visit storefront.reset_password_path(token)

        within '#reset_password_form' do
          fill_in 'password', with: @password
          click_button t('workarea.storefront.users.reset_password')
        end

        assert_current_path(storefront.login_path)
        assert(page.has_content?('Success'))

        within '#login_form' do
          fill_in 'email', with: @customer_email
          fill_in 'password', with: @password
          click_button t('workarea.storefront.users.login')
        end

        assert(page.has_content?('Success'))
      end

      def test_admin_resetting_a_password
        visit storefront.forgot_password_path

        within '#forgot_password_form' do
          fill_in 'email', with: @admin_email
          click_button t('workarea.storefront.forms.send')
        end

        token = User::PasswordReset.first.token
        visit storefront.reset_password_path(token)

        within '#reset_password_form' do
          fill_in 'password', with: @password
          click_button t('workarea.storefront.users.reset_password')
        end

        assert_current_path(storefront.login_path)
        assert(page.has_content?('Success'))

        delivery = ActionMailer::Base.deliveries.last
        assert_includes(delivery.subject, t('workarea.storefront.email.password_reset.subject'))
        assert_includes(delivery.to, @admin_email)
        assert_includes(delivery.html_part.body, token)

        within '#login_form' do
          fill_in 'email', with: @admin_email
          fill_in 'password', with: @password
          click_button t('workarea.storefront.users.login')
        end

        assert_current_path(admin.root_path)
      end

      def test_admin_forcing_password_resets
        Workarea.config.password_lifetime = 1.second
        sleep(1)

        # sign in for the first time
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: @admin_email
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        assert_current_path(storefront.change_password_path)

        # sign out
        reset_session!

        visit storefront.login_path

        # sign in again
        within '#login_form' do
          fill_in 'email', with: @admin_email
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end

        assert_current_path(storefront.change_password_path)

        # disallow all other page movement
        visit storefront.root_path
        assert_current_path(storefront.change_password_path)

        Workarea.config.password_lifetime = 1.hour
        fill_in 'old_password', with: 'W3bl1nc!'
        fill_in 'password', with: @password
        click_button t('workarea.storefront.users.change_password')

        assert_current_path(storefront.users_account_path)

        click_link t('workarea.storefront.users.logout')
        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: @admin_email
          fill_in 'password', with: @password
          click_button t('workarea.storefront.users.login')
        end
        assert_current_path(admin.root_path)
      end
    end
  end
end
