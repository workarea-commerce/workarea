require 'test_helper'

module Workarea
  module Storefront
    class StoreCreditSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      def test_purchasing_with_store_credit
        setup_checkout_specs
        add_user_data
        set_store_credit(100.to_m)

        start_user_checkout

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?(t('workarea.storefront.orders.store_credit')))

        assert(page.has_no_content?('Test Card')) # Don't show credit card if store credit covers full order amount
        assert(page.has_no_content?('XXXX-XXXX-XXXX-1'))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('12.84')) # Store credit amount
        assert(page.has_content?('0.00')) # Total less store credit

        click_button t('workarea.storefront.checkouts.place_order')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Thanks'))
        assert(page.has_content?(Order.placed.first.id))

        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('Ground'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?(t('workarea.storefront.orders.store_credit')))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('12.84')) # Store credit amount
        assert(page.has_content?('0.00')) # Total less store credit
      end

      def test_purchasing_with_store_credit_and_credit_card
        setup_checkout_specs
        add_user_data
        set_store_credit(4.to_m)

        start_user_checkout

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))
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
        assert(page.has_content?(t('workarea.storefront.orders.store_credit')))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('4.00')) # Store credit amount
        assert(page.has_content?('8.84')) # Total less store credit

        click_button t('workarea.storefront.checkouts.place_order')

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
        assert(page.has_content?(t('workarea.storefront.orders.store_credit')))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('4.00')) # Store credit amount
        assert(page.has_content?('8.84')) # Total less store credit
      end

      def test_paying_with_insufficient_store_credit
        setup_checkout_specs
        start_user_checkout
        set_store_credit(1.to_m)

        assert_current_path(storefront.checkout_addresses_path)
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('11.84')) # Remaing balance

        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_selector?('input.jquery-validation-error'))
      end

      private

      def set_store_credit(value)
        user = User.find_by_email('bcrouse@workarea.com')
        payment_profile = Payment::Profile.lookup(PaymentReference.new(user))
        payment_profile.update_attributes(store_credit: value)
      end
    end
  end
end
