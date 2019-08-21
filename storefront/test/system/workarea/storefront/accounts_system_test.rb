require 'test_helper'

module Workarea
  module Storefront
    class AccountsSystemTest < Workarea::SystemTest
      setup :set_user

      def set_user
        @user = create_user(
          email: 'bcrouse@workarea.com',
          password: 'W3bl1nc!',
          name: 'Ben Crouse'
        )
      end

      def test_signing_up
        visit storefront.login_path

        within '#signup_form' do
          fill_in 'email', with: 'accounts-test@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          check 'email_signup'
          click_button t('workarea.storefront.users.create_account')
        end

        assert_current_path(storefront.users_account_path)
        assert(page.has_content?('Success'))
      end

      def test_editing_account_details
        set_current_user(@user)
        visit storefront.edit_users_account_path

        within '#info_form' do
          fill_in 'email', with: 'bcrouse-change@workarea.com'
          fill_in 'first_name', with: 'Benjamin'
          fill_in 'last_name', with: 'Franklin'
          fill_in 'password', with: 'Passw0rd!'
          click_button t('workarea.storefront.forms.save')
        end

        assert(page.has_content?('Success'))
        assert(page.has_content?('bcrouse-change@workarea.com'))
        assert(page.has_content?('Benjamin Franklin'))
      end

      def test_account_dashboard
        set_current_user(@user)

        @user.auto_save_shipping_address(
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          street_2: 'Second Floor',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US',
          phone_number: '2159251800'
        )

        @user.auto_save_billing_address(
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '1019 S. 47th St.',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19143',
          country: 'US',
          phone_number: '2159251800'
        )

        create_placed_order(id: 'ORDER_1234', user_id: @user.id)

        fulfilled_order = create_placed_order(
          id: 'ORDER_5678',
          user_id: @user.id
        )
        shipped_item = fulfilled_order.items.first
        fulfillment = Fulfillment.find(fulfilled_order.id)
        fulfillment.ship_items('1Z', [
          { 'id' => shipped_item.id, 'quantity' => shipped_item.quantity }
        ])

        visit storefront.users_account_path

        assert(page.has_content?('ORDER_1234'))
        assert(page.has_content?('Open'))
        assert(page.has_content?('ORDER_5678'))
        assert(page.has_content?('Shipped'))
        assert(page.has_content?(t('workarea.storefront.orders.track_package')))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('1019 S. 47th St.'))
      end
    end
  end
end
