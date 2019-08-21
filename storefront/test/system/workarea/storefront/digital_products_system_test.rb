require 'test_helper'

module Workarea
  module Storefront
    class DigitalProductsSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      def test_checking_out_with_a_digital_product
        setup_checkout_specs

        Order.first.items.delete_all

        product = create_product(
          name: 'Digital Product',
          digital: true,
          variants: [
            { sku: 'SKU1', regular: 10.to_m },
            { sku: 'SKU2', regular: 15.to_m },
            { sku: 'SKU3', regular: 25.to_m }
          ]
        )

        visit storefront.product_path(product)

        within '.product-details__add-to-cart-form' do
          select product.skus.first, from: 'sku'
          click_button t('workarea.storefront.products.add_to_cart')
        end

        assert(page.has_content?('Success'))

        start_guest_checkout

        assert_current_path(storefront.checkout_addresses_path)

        fill_in_email
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_confirmation_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?(t('workarea.storefront.flash_messages.order_placed')))
        assert(page.has_content?(Order.first.id))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_content?('Test Card'))
        assert(page.has_content?('XX-1'))

        assert(page.has_content?('Digital Product'))
        assert(page.has_content?('$10.00'))
      end

      def test_order_not_requiring_shipping
        setup_checkout_specs
        start_guest_checkout

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

        # switch to digital product

        Order.first.items.delete_all

        product = create_product(
          name: 'Digital Product',
          digital: true,
          variants: [
            { sku: 'SKU1', regular: 10.to_m },
            { sku: 'SKU2', regular: 15.to_m },
            { sku: 'SKU3', regular: 25.to_m }
          ]
        )

        visit storefront.product_path(product)

        within '.product-details__add-to-cart-form' do
          select product.skus.first, from: 'sku'
          click_button t('workarea.storefront.products.add_to_cart')
        end

        click_link t('workarea.storefront.carts.checkout')

        assert_current_path(storefront.checkout_addresses_path)

        fill_in_email
        fill_in_billing_address
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        assert_current_path(storefront.checkout_payment_path)
        assert(page.has_content?('Success'))

        assert(page.has_content?('1019 S. 47th St.'))
        assert(page.has_content?('Philadelphia'))
        assert(page.has_content?('PA'))
        assert(page.has_content?('19143'))

        assert(page.has_no_content?("#{t('workarea.storefront.orders.tax')} $1.40"))
        assert(page.has_no_content?("#{t('workarea.storefront.orders.total')} $31.40"))
        assert(page.has_content?("#{t('workarea.storefront.orders.shipping')} #{t('workarea.storefront.checkouts.not_applicable')}"))
        assert(page.has_content?("#{t('workarea.storefront.orders.tax')} $0.00"))
        assert(page.has_content?("#{t('workarea.storefront.orders.total')} $10.00"))
      end
    end
  end
end
