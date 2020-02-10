require 'test_helper'

module Workarea
  module Storefront
    class LoggedInCheckoutSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :setup_checkout_specs
      setup :add_user_data
      setup :start_user_checkout

      def test_starting_checkout_without_cart
        Order.delete_all
        visit storefront.checkout_path

        assert_current_path(storefront.cart_path)
        assert(page.has_content?('Error'))
      end

      def test_moving_between_cart_and_checkout_until_expiration
        assert_current_path(storefront.checkout_payment_path)
        visit storefront.cart_path
        first(:link, t('workarea.storefront.carts.checkout')).click
        assert_current_path(storefront.checkout_payment_path)

        travel(30.minutes) do
          visit storefront.checkout_addresses_path
          assert_current_path(storefront.cart_path)
          assert(page.has_content?('Warning'))
        end
      end

      def test_starting_checkout_as_guest
        travel(30.minutes) do
          # Simulates the browser expiring the session cookie
          session_cookie = Rails.application.config.session_options[:key]
          page.driver.browser.manage.delete_cookie(session_cookie)

          visit storefront.checkout_path

          refute_equal('Ben', find_field('shipping_address[first_name]').value)
          refute_equal('Crouse', find_field('shipping_address[last_name]').value)
          refute_equal('22 S. 3rd St.', find_field('shipping_address[street]').value)
          refute_equal('Philadelphia', find_field('shipping_address[city]').value)
          refute_equal('19106', find_field('shipping_address[postal_code]').value)
          refute_equal('PA', find_field('shipping_address_region_select').value)
          refute_equal('215-925-1800', find_field('shipping_address[phone_number]').value)

          uncheck :same_as_shipping
          refute_equal('Ben', find_field('billing_address[first_name]').value)
          refute_equal('Crouse', find_field('billing_address[last_name]').value)
          refute_equal('1019 S. 47th St.', find_field('billing_address[street]').value)
          refute_equal('Philadelphia', find_field('billing_address[city]').value)
          refute_equal('19143', find_field('billing_address[postal_code]').value)
          refute_equal('PA', find_field('billing_address_region_select').value)
          refute_equal('215-925-1800', find_field('billing_address[phone_number]').value)
        end
      end

      def test_preselecting_addresses_from_saved_addresses
        Workarea.config.countries = [Country['US'], Country['CA']]

        add_user_data

        user = User.find_by_email('bcrouse@workarea.com')
        user.auto_save_shipping_address(
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '1525 Robson St.',
          city: 'Vancouver',
          region: 'BC',
          postal_code: 'V6G 1C3',
          country: 'CA',
          phone_number: '18444710783'
        )

        visit storefront.checkout_addresses_path

        select 'Ben Crouse 1019 S. 47th St. Philadelphia PA 19143', from: 'saved_addresses_0'
        assert_equal(find('select[name="shipping_address[country]"]').value, 'US')
        assert_equal(find('#shipping_address_region_select').value, 'PA')

        select 'Ben Crouse 1525 Robson St. Vancouver BC V6G 1C3', from: 'saved_addresses_0'
        assert_equal(find('select[name="shipping_address[country]"]').value, 'CA')
        assert_equal(find('#shipping_address_region_select').value, 'BC')

        select 'Ben Crouse 1019 S. 47th St. Philadelphia PA 19143', from: 'saved_addresses_1'
        assert_equal(find('select[name="billing_address[country]"]').value, 'US')
        assert_equal(find('#billing_address_region_select').value, 'PA')

        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_no_content?('22 S. 3rd St.'))
      end

      def test_express_checkout
        assert_current_path(storefront.checkout_payment_path)

        assert(page.has_content?('Ben'))
        assert(page.has_content?('Crouse'))
        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('19143'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('US'))
        assert(page.has_content?('215-925-1800'))

        assert(page.has_content?('Ben'))
        assert(page.has_content?('Crouse'))
        assert(page.has_content?('22 S. 3rd St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('19106'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('US'))
        assert(page.has_content?('215-925-1800'))

        credit_card_id = Payment::SavedCreditCard.first.id
        assert(find_field("payment_#{credit_card_id}"))
        refute(find_field('payment_new_card')[:checked])

        assert(page.has_content?('Integration Product'))
        assert(page.has_content?('SKU'))

        assert(page.has_content?('5.00')) # Subtotal
        assert(page.has_content?('7.00')) # Shipping
        assert(page.has_content?('0.84')) # Tax
        assert(page.has_content?('12.84')) # Total

        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_confirmation_path)
        assert(page.has_content?('Success'))
      end

      def test_editing_shipping_options
        create_shipping_service(
          name: 'Next Day',
          tax_code: '001',
          rates: [{ price: 20.to_m }]
        )

        visit storefront.checkout_shipping_path
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        visit storefront.checkout_shipping_path
        choose "shipping_service_Next_Day"
        within('.checkout-step-summary') do
          assert(page.has_content?(/Next Day - .20\.00/))
        end
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        visit storefront.checkout_shipping_path
        assert(find_field("shipping_service_Next_Day").checked?)

        visit storefront.checkout_payment_path
        assert(page.has_content?('20.00')) # Shipping
        assert(page.has_content?('1.75'))  # Tax
        assert(page.has_content?('26.75')) # Total price
      end

      def test_successfully_compelting_checkout
        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Info'))

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

      def test_checking_out_with_discount
        visit storefront.checkout_addresses_path
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
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)

        assert(page.has_content?(/Ground .0\.00/))
        assert(page.has_content?(/Next Day .20\.00/))

        assert(page.has_content?('0.35')) # Tax
        assert(page.has_content?('5.35')) # Total
      end

      def test_failed_payment_authorization
        assert_current_path(storefront.checkout_payment_path)
        choose 'payment_new_card'
        fill_in_credit_card
        fill_in 'credit_card[number]', with: '2'
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_place_order_path)
        assert(page.has_content?('Error'))

        credit_card_id = Payment::SavedCreditCard.first.id

        refute(find_field("payment_#{credit_card_id}")[:checked])
        assert(find_field('payment_new_card')[:checked])

        choose 'payment_new_card'
        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_confirmation_path)
        assert(page.has_content?('Success'))
      end

      def test_validation_errors
        visit storefront.checkout_addresses_path
        fill_in 'shipping_address[first_name]', with: ''
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_addresses_path)
        assert(page.has_selector?('input.jquery-validation-error'))
        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        assert_current_path(storefront.checkout_shipping_path)
        assert(page.has_content?('Success'))
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))
        choose 'payment_new_card'
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_selector?('input.jquery-validation-error'))
      end

      def test_unavailable_inventory
        assert_current_path(storefront.checkout_payment_path)

        Inventory::Sku.find('SKU').update_attributes!(available: 0)
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.cart_path)
        assert(page.has_content?('Error'))
        assert(page.has_content?('SKU is unavailable'))
      end
    end
  end
end
