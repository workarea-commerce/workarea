require 'test_helper'

module Workarea
  class OrderMergeTest < TestCase
    def test_merge
      create_product(id: 'PROD', variants: [{ sku: 'SKU3' }])

      original = Order.new(
        items: [
          { product_id: 'PROD', sku: 'SKU1' },
          { product_id: 'PROD', sku: 'SKU2' }
        ]
      )

      other = Order.new(
        promo_codes: %w(PROMOCODE),
        items: [
          { product_id: 'PROD', sku: 'SKU2' },
          { product_id: 'PROD', sku: 'SKU3' }
        ]
      )

      OrderMerge.new(original).merge(other)

      assert_equal(3, original.items.count)
      assert_equal([1, 1, 1], original.items.map(&:quantity))
      assert_equal(%w(PROMOCODE), original.promo_codes)
    end
  end
end
