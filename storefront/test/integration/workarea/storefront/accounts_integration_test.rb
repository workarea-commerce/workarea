require 'test_helper'

module Workarea
  module Storefront
    class AccountsIntegrationTest < Workarea::IntegrationTest
      def test_creating_an_account
        post storefront.users_account_path,
          params: {
            email: 'accounts-test@workarea.com',
            password: 'W3bl1nc!',
            email_signup: true
          }

        assert_redirected_to(storefront.users_account_path)

        user = User.find_by(email: 'accounts-test@workarea.com')
        assert(user.authenticate('W3bl1nc!').is_a?(User))

        email_signups = Email::Signup.where(email: 'accounts-test@workarea.com')
        assert_equal(email_signups.count, 1)

        if Workarea.config.send_transactional_emails
          email = ActionMailer::Base.deliveries.last
          assert(email.to.include?('accounts-test@workarea.com'))
        end
      end

      def test_not_signing_up_for_email
        post storefront.users_account_path,
          params: {
            email: 'accounts-test@workarea.com',
            password: 'W3bl1nc!'
          }

        assert(Email::Signup.count.zero?)
      end

      def test_signup_failure
        post storefront.users_account_path,
          params: {
            email: 'accounts-test@workarea.com',
            password: ''
          }

        assert_equal(422, response.status)
      end

      def test_updating_account_info
        user = create_user(
          email: 'bcrouse@workarea.com',
          password: 'W3bl1nc!',
          name: 'Ben Crouse'
        )

        post storefront.login_path,
          params: {
            email: 'bcrouse@workarea.com',
            password: 'W3bl1nc!'
          }

        patch storefront.users_account_path,
          params: {
            email: 'bcrouse-change@workarea.com',
            first_name: 'Benjamin',
            last_name: 'Franklin',
            password: 'Passw0rd!'
          }

        user.reload

        assert_equal(user.email, 'bcrouse-change@workarea.com')
        assert_equal(user.first_name, 'Benjamin')
        assert_equal(user.last_name, 'Franklin')
        assert(user.authenticate('Passw0rd!').is_a?(User))
      end

      def test_updating_failure
        set_current_user(
          create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        )

        patch storefront.users_account_path,
          params: {
            email: 'bcrouse-change@workarea.com',
            password: 'a'
          }

        assert(response.ok?)
      end

      def test_updating_email_signup
        set_current_user(
          create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
        )

        patch storefront.users_account_path, params: { email_signup: true }
        assert(Email.signed_up?('bcrouse@workarea.com'))

        patch storefront.users_account_path, params: { email_signup: false }
        refute(Email.signed_up?('bcrouse@workarea.com'))
      end

      def test_login_required
        get storefront.users_account_path
        assert_redirected_to(storefront.login_path)

        get storefront.edit_users_account_path
        assert_redirected_to(storefront.login_path)

        patch storefront.users_account_path
        assert_redirected_to(storefront.login_path)
      end

      def test_logout_required
        set_current_user(create_user)

        post storefront.users_account_path,
          params: {
            email: 'accounts-test@workarea.com',
            password: 'W3bl1nc!',
            email_signup: true
          }

        assert_redirected_to(storefront.login_path)
      end

      def test_no_extra_order_id_cookies
        user = create_user(password: 'Passw0rd!')
        post storefront.login_path,
          params: { email: user.email, password: 'Passw0rd!' }

        follow_redirect!
        assert(cookies[:order_id].blank?)

        delete storefront.logout_path

        follow_redirect!
        assert(cookies[:order_id].blank?)

        post storefront.login_path,
          params: { email: user.email, password: 'Passw0rd!' }

        follow_redirect!
        assert(cookies[:order_id].blank?)
      end
    end
  end
end
