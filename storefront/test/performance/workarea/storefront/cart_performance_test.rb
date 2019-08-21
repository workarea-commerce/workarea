require 'test_helper'

module Workarea
  module Storefront
    class CartPerformanceTest < Workarea::PerformanceTest
      setup :setup_cart

      def setup_cart
        @products = []
        Sidekiq::Callbacks.disable do
          10.times do |i|
            product = create_complex_product(name: "Test Product #{i}")

            post storefront.cart_items_path,
              params: {
                product_id: product.id,
                sku: product.skus.first,
                quantity: 2 + i
              }

              @products << product
          end

          @categories = Array.new(5) do |i|
            create_category(name: "Test Category #{i}", product_ids: @products.sample(4).map(&:id))
          end
        end

        BulkIndexProducts.perform_by_models(@products)

        order_total = create_order_total_discount(promo_codes: %w(TESTCODE))
        buy_some = create_buy_some_get_some_discount(product_ids: [@products.first.id])
        category = create_category_discount(category_ids: [@categories.first.id])
        free_gift = create_free_gift_discount(sku: create_product.skus.first, product_ids: [@products.second.id])
        product_attribute = create_product_attribute_discount(attribute_name: 'Color', attribute_value: 'Red')
        product = create_product_discount(product_ids: @products.map(&:id))
        fixed_price = create_quantity_fixed_price_discount(product_ids: [@products.third.id])

        order_total.update_attributes!(compatible_discount_ids: [category.id, product_attribute.id, free_gift.id])
        buy_some.update_attributes!(compatible_discount_ids: [product.id, fixed_price.id, order_total.id])
        category.update_attributes!(compatible_discount_ids: [fixed_price.id,  product_attribute.id])

        post storefront.add_promo_code_to_cart_path, params: { promo_code: 'TESTCODE' }
      end

      def test_cart_with_many_discounts
        get storefront.cart_path
        assert(response.ok?)
      end
    end
  end
end
