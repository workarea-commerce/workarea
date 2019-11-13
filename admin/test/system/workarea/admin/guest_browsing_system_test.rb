require 'test_helper'

module Workarea
  module Admin
    class GuestBrowsingSystemTest < SystemTest
      include Storefront::SystemTest

      def test_browsing_as_a_guest
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

        visit admin.users_path
        click_link t('workarea.admin.users.index.browse_as_guest')

        assert_current_path(storefront.root_path)
        assert(page.has_content?('Success'))

        click_link t('workarea.storefront.users.account')
        assert_current_path(storefront.login_path)

        find('.message__dismiss-button').click

        within_frame find('.admin-toolbar') do
          click_button t('workarea.admin.toolbar.stop_guest_browsing')
        end

        assert_current_path(admin.root_path)
        assert(page.has_content?('Success'))
      end

      def test_completing_an_order_while_guest_browsing
        admin_user = create_user(
          email: 'admin_user@workarea.com',
          password: 'W3bl1nc!',
          super_admin: true
        )

        visit storefront.login_path

        within '#login_form' do
          fill_in 'email', with: 'admin_user@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button 'login'
        end

        visit admin.users_path
        click_link t('workarea.admin.users.index.browse_as_guest')

        setup_checkout_specs
        start_guest_checkout

        assert_current_path(storefront.checkout_addresses_path)

        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')

        order = Order.placed.first
        assert_current_path(admin.order_path(order))
      end
    end
  end
end
