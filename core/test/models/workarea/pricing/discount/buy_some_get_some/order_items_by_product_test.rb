require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class BuySomeGetSome
        class OrderItemsByProductTest < TestCase
          def test_products
            order = create_order(
              items: [
                { product_id: 'PROD1', sku: 'SKU1', quantity: 2, category_ids: %w(CAT1) },
                { product_id: 'PROD1', sku: 'SKU2', quantity: 3, category_ids: %w(CAT1) }
              ]
            )

            products = Discount::BuySomeGetSome::OrderItemsByProduct.new(order).products

            assert_equal(1, products.length)
            assert_equal(2, products.first.items.length)
            assert_equal('PROD1', products.first.id)
            assert_equal(5, products.first.quantity)
            assert_equal(%w(CAT1), products.first.category_ids)
          end
        end
      end
    end
  end
end
