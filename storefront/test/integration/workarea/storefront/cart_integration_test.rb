require 'test_helper'

module Workarea
  module Storefront
    class CartIntegrationTest < Workarea::IntegrationTest
      setup :set_inventory
      setup :set_product

      def set_inventory
        @inventory = create_inventory(id: 'SKU1', policy: 'standard', available: 2)
      end

      def set_product
        @product = create_product(
          name: 'Integration Product',
          variants: [
            { sku: 'SKU1', regular: 5.to_m },
            { sku: 'SKU2', regular: 6.to_m }
          ]
        )
      end

      def order
        Order.first
      end

      def test_can_add_a_promo_code_to_the_cart
        create_order_total_discount(promo_codes: %w(TESTCODE))

        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'TESTCODE', return_to: '/foo' }

        assert_redirected_to('/foo')

        post storefront.add_promo_code_to_cart_path,
          params: {
            promo_code: 'TESTCODE',
            return_to: 'http://www.example.com/foo'
          }

        assert_redirected_to('/foo')
      end

      def test_handles_promo_code_failure
        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'TESTCODE' }

        assert_redirected_to(storefront.cart_path(promo_code: 'TESTCODE'))

        assert(flash[:error].present?)
        assert(order.blank?)
      end

      def test_flashes_error_for_redeemed_single_use_promo_codes
        discount = create_product_discount(
          single_use: true,
          promo_codes: %w(TESTCODE)
        )

        discount.redemptions.create!(
          discount_id: discount.id,
          email: 'user@workarea.com'
        )

        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        order.update_attributes!(email: 'user@workarea.com')

        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'TESTCODE' }

        assert(flash[:error].present?)
        assert_redirected_to(storefront.cart_path(promo_code: 'TESTCODE'))
      end

      def test_can_merge_carts_based_on_token
        post storefront.cart_items_path,
          params: {
            product_id: @product.id,
            sku: @product.skus.first,
            quantity: 1
          }

        controller.reset_session

        get storefront.resume_cart_path(order.token)

        assert_redirected_to(storefront.cart_path)
        assert_equal(@product.id, order.items.first.product_id)
        assert_equal(@product.skus.first, order.items.first.sku)
        assert_equal(1, order.items.first.quantity)
      end

      def test_does_not_cache_if_there_is_a_flash_message_present
        # Sets an invalid promo code flash message
        post storefront.add_promo_code_to_cart_path,
          params: { promo_code: 'TESTCODE' }

        get storefront.root_path
        refute_match(/public/, response.headers['Cache-Control'])
      end
    end
  end
end
