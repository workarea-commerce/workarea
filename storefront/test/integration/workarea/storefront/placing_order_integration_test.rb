require 'test_helper'

module Workarea
  module Storefront
    class PlacingOrderIntegrationTest < Workarea::IntegrationTest
      def test_validating_shipping_option_when_placing_order
        create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        create_shipping_service(
          name: 'Ground',
          tax_code: '001',
          rates: [
            { price: 7, tier_min: 0, tier_max: 4.99 },
            { price: 0, tier_min: 5, tier_max: 9999 }
          ]
        )

        product = create_product(
          name: 'Integration Product',
          variants: [
            {
              sku: 'SKU1',
              regular: 4.to_m,
              tax_code: '001'
            }
          ]
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
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '12 N. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              city: 'Philadelphia',
              region: 'PA',
              postal_code: '19106',
              country: 'US',
              phone_number: '2159251800'
            }
          }

        order = Order.first
        assert_equal(0.to_m, order.shipping_total)

        # Change the quantity to reduce the order price to change which
        # shipping rate tier the order falls into
        patch storefront.cart_item_path(order.items.first),
          params: { quantity: 1 }

        patch storefront.checkout_place_order_path,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '1',
              month: 1,
              year: next_year,
              cvv: '999'
            }
          }

        assert_redirected_to(storefront.checkout_shipping_path)
        assert(flash[:error].present?)

        order.reload
        refute(order.placed?)
      end
    end
  end
end
