require 'test_helper'

module Workarea
  module Storefront
    class GuestCheckoutSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :setup_checkout_specs
      setup :start_guest_checkout

      def test_checking_out_with_empty_cart
        Order.delete_all
        visit storefront.checkout_path

        assert(page.has_content?('Error'))
        assert_current_path(storefront.cart_path)
      end

      def test_moving_between_cart_and_checkout_until_expiration
        assert_current_path(storefront.checkout_addresses_path)

        visit storefront.cart_path
        first(:link, t('workarea.storefront.carts.checkout')).click
        assert_current_path(storefront.checkout_addresses_path)

        travel_to(30.minutes.from_now) do
          visit storefront.checkout_addresses_path

          assert_current_path(storefront.cart_path)
          assert(page.has_content?('Warning'))
        end
      end

      def test_editing_address
        assert_current_path(storefront.checkout_addresses_path)

        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))

        visit storefront.checkout_addresses_path

        assert_equal('Ben', find_field('shipping_address[first_name]').value)
        assert_equal('Crouse', find_field('shipping_address[last_name]').value)
        assert_equal('22 S. 3rd St.', find_field('shipping_address[street]').value)
        assert_equal('Philadelphia', find_field('shipping_address[city]').value)
        assert_equal('19106', find_field('shipping_address[postal_code]').value)
        assert_equal('PA', find_field('shipping_address_region_select').value)
        assert_equal('US', find_field('shipping_address[country]').value)
        assert_equal('215-925-1800', find_field('shipping_address[phone_number]').value)

        fill_in 'shipping_address[first_name]', with: 'Benjamin'
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))

        visit storefront.checkout_addresses_path
        assert_equal('Benjamin', find_field('shipping_address[first_name]').value)
      end

      def test_skipping_address_form
        assert_current_path(storefront.checkout_addresses_path)
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_addresses_path)
        assert(page.has_selector?('input.jquery-validation-error'))
      end

      def test_editing_address_with_shipping_option
        create_shipping_service(
          name: 'New Jersey Ground',
          tax_code: '001',
          regions: ['NJ'],
          country: 'US',
          rates: [{ price: 10.to_m }]
        )

        assert_current_path(storefront.checkout_addresses_path)

        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Ground'))
        assert(page.has_content?('7.00'))  # Shipping

        visit storefront.checkout_addresses_path

        select 'New Jersey', from: 'shipping_address_region_select'
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))

        visit storefront.checkout_payment_path

        assert(page.has_content?('New Jersey Ground'))
        assert(page.has_content?('10.00'))  # Shipping
      end

      def test_editing_shipping_options
        create_shipping_service(
          name: 'Next Day',
          tax_code: '001',
          rates: [{ price: 20.to_m }]
        )

        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        visit storefront.checkout_shipping_path
        choose "shipping_service_Next_Day"
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        visit storefront.checkout_shipping_path
        assert(find_field("shipping_service_Next_Day").checked?)

        visit storefront.checkout_payment_path
        assert(page.has_content?('1.75'))  # Tax
        assert(page.has_content?('26.75')) # Total price
      end

      def test_skipping_payment_form
        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_selector?('input.jquery-validation-error'))
      end

      def test_failed_payment_authorization
        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        fill_in_credit_card
        fill_in 'credit_card[number]', with: '2'
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_place_order_path)
        assert(page.has_content?('Error'))
      end

      def test_fraud_payment_failure
        assert_current_path(storefront.checkout_addresses_path)
        fill_in 'email', with: 'decline@workarea.com'
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        fill_in_credit_card
        fill_in 'credit_card[number]', with: '1'
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_place_order_path)
        assert(page.has_content?('Error'))
      end

      def test_unavailable_inventory
        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        fill_in_credit_card

        Inventory::Sku.find('SKU').update_attributes!(available: 0)
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.cart_path)
        assert(page.has_content?('Error'))
        assert(page.has_content?('SKU is unavailable'))
      end

      def test_checking_out_with_a_discount
        visit storefront.checkout_addresses_path
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        create_order_total_discount(
          name: 'Testing Discount',
          amount_type: 'flat',
          amount: 1,
          promo_codes: ['PROMOCODE']
        )

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        fill_in 'promo_code', with: 'PROMOCODE'
        click_button t('workarea.storefront.carts.add')

        assert(page.has_content?('Success'))
        assert(page.has_content?('Testing Discount'))
        assert(page.has_content?('5.00'))  # Subtotal
        assert(page.has_content?('7.00'))  # Shipping
        assert(page.has_content?('0.77'))  # Tax
        assert(page.has_content?('1.00'))  # Discount
        assert(page.has_content?('11.77')) # Total
      end

      def test_checking_out_with_shipping_discount
        create_shipping_service(
          name: 'Next Day',
          tax_code: '001',
          rates: [{ price: 20.to_m }]
        )

        create_shipping_discount(
          name: 'Free Ground Shipping',
          amount: 0,
          shipping_service: 'Ground',
          promo_codes: ['FREESHIPPING']
        )

        visit storefront.cart_path
        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        fill_in 'promo_code', with: 'FREESHIPPING'
        click_button t('workarea.storefront.carts.add')

        visit storefront.checkout_addresses_path
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)

        assert(page.has_content?(/Ground .0.00/))
        assert(page.has_content?(/Next Day .20.00/))

        assert(page.has_content?('0.35')) # Tax
        assert(page.has_content?('5.35')) # Total
      end

      def test_successfully_checking_out
        assert_current_path(storefront.checkout_addresses_path)
        fill_in_email
        fill_in_shipping_address
        uncheck 'same_as_shipping'
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))

        click_button t('workarea.storefront.checkouts.shipping_instructions_prompt')
        instruction = 'Doorbeel broken, please knock'
        fill_in :shipping_instructions, with: instruction

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

        assert(page.has_content?(instruction))

        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_confirmation_path)

        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.storefront.flash_messages.order_placed')))
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

        assert(page.has_content?(instruction))

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('12.84')) # Total
      end

      def test_creating_an_account
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

        assert_current_path(storefront.checkout_confirmation_path)
        fill_in 'password', with: 'W3bl1nc!'
        check 'email_signup'
        click_button t('workarea.storefront.users.create_account')

        assert_current_path(storefront.users_account_path)

        assert(page.has_content?('Success'))
        assert(page.has_content?('Ben'))
        assert(page.has_content?('Crouse'))
        assert(page.has_content?(Order.first.id))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('XX-1'))
      end

      def test_creating_an_account_during_checkout
        click_link t('workarea.storefront.checkouts.login_title')
        fill_in 'create_account_email', with: 'test@workarea.com'
        fill_in 'create_account_password', with: 'W3bl1nc!'
        click_button t('workarea.storefront.users.create_account')

        assert_current_path(storefront.checkout_addresses_path)
        assert(page.has_no_content?(t('workarea.storefront.checkouts.email')))
      end

      def test_logging_in_during_checkout
        create_user(email: 'test@workarea.com', password: 'W3bl1nc!')

        click_link t('workarea.storefront.checkouts.login_title')
        fill_in 'log_in_email', with: 'test@workarea.com'
        fill_in 'log_in_password', with: 'W3bl1nc!'
        click_button t('workarea.storefront.users.login')

        assert_current_path(storefront.checkout_addresses_path)
        assert(page.has_no_content?(t('workarea.storefront.checkouts.email')))
      end

      def test_regionless_country
        @countries = Workarea.config.countries
        Workarea.config.countries = [Country['US'], Country['GF']]  # French Guiana has no regions

        start_guest_checkout  # again, to refresh the country list

        fill_in_email
        fill_in_shipping_address

        assert(page.has_selector?('[name="shipping_address[region]"]', visible: false))

        select 'French Guiana', from: 'shipping_address_country'

        assert(page.has_selector?('#shipping_address_region_select', visible: false))
        assert(page.has_selector?('[name="shipping_address[region]"]', visible: true))

        fill_in 'shipping_address[region]', with: ''

        click_button t('workarea.storefront.checkouts.continue_to_shipping')
        assert(page.has_content?('Success'))
      ensure
        Workarea.config.countries = @countries
      end
    end
  end
end
