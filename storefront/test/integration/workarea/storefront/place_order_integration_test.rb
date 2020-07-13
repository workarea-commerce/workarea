require 'test_helper'

module Workarea
  module Storefront
    class PlaceOrderIntegrationTest < Workarea::IntegrationTest
      setup :setup_checkout

      def setup_checkout
        create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        product = create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )

        create_shipping_service(
          carrier: 'UPS',
          name: 'Ground',
          service_code: '03',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        patch storefront.checkout_addresses_path,
          params: {
            email: 'bcrouse@workarea.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }

        patch storefront.checkout_shipping_path
      end

      def test_no_lock_on_order
        order.lock!

        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '1',
              month:  1,
              year:   next_year,
              cvv:    '999'
            }
          }

        assert_redirected_to(storefront.cart_path)
      end

      def test_payment_error_handling
        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '2',
              month:  1,
              year:   next_year,
              cvv:    '999'
            }
          }

        assert(response.ok?)
        assert_match('Payment', response.body)
      end

      def test_clearing_of_successful_order
        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '1',
              month:  1,
              year:   next_year,
              cvv:    '999'
            }
          }

        assert(session[:order_id].blank?)
      end

      def test_no_access_to_confirmation_page_with_no_completed_order
        get storefront.checkout_confirmation_path
        assert_redirected_to(storefront.cart_path)
      end

      def test_clearing_completed_order_cookie_on_logout
        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '1',
              month:  1,
              year:   next_year,
              cvv:    '999'
            }
          }

        get storefront.checkout_confirmation_path
        assert(response.ok?)

        delete storefront.logout_path
        get storefront.checkout_confirmation_path
        assert_redirected_to(storefront.cart_path)
      end

      private

      def order
        @order ||= Order.first
      end
    end
  end
end
