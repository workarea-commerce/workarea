require 'test_helper'

module Workarea
  module Admin
    class ImpersonationSystemTest < SystemTest
      def test_impersonating_a_user
        user = create_user(email: 'impersonated@workarea.com')
        create_user(
          email: 'bcrouse@workarea.com',
          password: 'W3bl1nc!',
          super_admin: true
        )

        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button 'login'
        end

        visit admin.user_path(user)
        click_button t('workarea.admin.users.show.impersonate')

        assert_equal(storefront.users_account_path, current_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('impersonated@workarea.com'))

        visit storefront.root_path

        within_frame find('.admin-toolbar') do
          assert(page.has_content?('impersonated@workarea.com'))
          click_button 'Stop Impersonation'
        end

        assert_equal(admin.user_path(user), current_path)
        assert(page.has_content?('Success'))

        find('.view').hover # Ensure tooltipster menu isn't open
        assert(page.has_content?('bcrouse@workarea.com'))

        visit storefront.users_account_path
        assert(page.has_no_content?('impersonated@workarea.com'))

        visit admin.user_path(user)
        click_button t('workarea.admin.users.show.impersonate')

        visit admin.root_path
        within '.header' do
          assert(page.has_content?('impersonated@workarea.com'))
          click_button 'Stop Impersonation'
        end

        assert_equal(admin.user_path(user), current_path)
        assert(page.has_content?('Success'))
      end
    end
  end
end
