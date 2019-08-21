require 'test_helper'

module Workarea
  module Storefront
    module Users
      class PasswordsIntegrationTest < Workarea::IntegrationTest
        setup :set_user

        def set_user
          @user = create_user(email: 'passwords@workarea.com', password: 'Workar3a!')
        end

        def test_creates_a_password_reset
          post storefront.forgot_password_path,
            params: { email: 'passwords@workarea.com' }

          assert_equal(1, User::PasswordReset.count)
          result = User::PasswordReset.first
          assert_equal(@user.id, result.user_id)
        end

        def test_sends_an_email
          post storefront.forgot_password_path,
            params: { email: 'passwords@workarea.com' }

          delivery = ActionMailer::Base.deliveries.last
          assert_includes(delivery.subject, 'Password')
          assert_includes(delivery.to, 'passwords@workarea.com')
          assert_includes(delivery.html_part.body, User::PasswordReset.first.token)
        end

        def test_handles_a_missing_password_reset
          get storefront.reset_password_path(token: 'foo')
          assert_redirected_to(storefront.forgot_password_path)
        end

        def test_handles_an_unsuccessful_reset
          reset = User::PasswordReset.setup!('passwords@workarea.com')
          patch storefront.reset_password_path(token: reset.token),
            params: { password: '' }

          assert(flash[:error].present?)
          assert(response.redirect?)
        end
      end
    end
  end
end
