require 'test_helper'

module Workarea
  module Storefront
    class NoJsSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      driven_by :rack_test

      def test_successfully_completing_checkout
        setup_checkout_specs
        start_guest_checkout

        assert_current_path(storefront.checkout_addresses_path)
        click_button t('workarea.storefront.checkouts.continue_to_shipping')
        assert_current_path(storefront.checkout_addresses_path)
        assert(page.has_content?('Error'))

        fill_in_email
        fill_in_shipping_address
        fill_in 'shipping_address[region]', with: 'PA'
        fill_in_billing_address
        fill_in 'billing_address[region]', with: 'PA'
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('12.84')) # Total

        click_button t('workarea.storefront.checkouts.place_order')
        assert_current_path(storefront.checkout_place_order_path)
        assert(page.has_content?('Error'))

        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_confirmation_path)

        assert(page.has_content?('Success'))
        assert(page.has_content?('Thanks'))
        assert(page.has_content?(Order.first.id))

        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Test Card'))
        assert(page.has_content?('XX-1'))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('12.84')) # Total
      end
    end
  end
end
