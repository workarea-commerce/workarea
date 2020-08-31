require 'test_helper'

module Workarea
  class Order
    class ItemTest < TestCase
      def item
        @item ||= Order::Item.new
      end

      def test_matches_categories?
        item.category_ids = %w(one two)
        assert(item.matches_categories?('one'))
        assert(item.matches_categories?(%w(one two)))
        refute(item.matches_categories?('three'))
      end

      def test_matches_products?
        item.product_id = 'one'
        assert(item.matches_products?('one'))
        assert(item.matches_products?(%w(one two)))
        refute(item.matches_products?('three'))
      end

      def test_original_unit_price
        item.quantity = 2
        assert_equal(0.to_m, item.original_unit_price)

        item.price_adjustments.build(amount: 4.to_m, quantity: 2)
        assert_equal(2.to_m, item.original_unit_price)
      end

      def test_current_unit_price
        item.quantity = 2
        assert_equal(0.to_m, item.current_unit_price)

        item.price_adjustments.build(amount: 4.to_m, quantity: 2, price: 'item')
        assert_equal(2.to_m, item.current_unit_price)

        item.price_adjustments.build(amount: -0.4.to_m, quantity: 2, price: 'order')
        assert_equal(2.to_m, item.current_unit_price)

        # TODO: v4 look to rework discounts that make partial quantity "free"
        # without affecting misrepresenting current_unit_price.
        item.price_adjustments.build(amount: -2.to_m, quantity: 1, price: 'item')
        assert_equal(1.to_m, item.current_unit_price)
      end

      def test_on_sale?
        refute(item.on_sale?)

        item.price_adjustments.build(
          amount: 4.to_m,
          quantity: 1,
          data: { 'on_sale' => true }
        )
        assert(item.on_sale?)
      end

      def test_fulfilled_by?
        item.fulfillment = 'shipping'
        assert(item.fulfilled_by?(:shipping))
        assert(item.fulfilled_by?(:shipping, :download))
        refute(item.fulfilled_by?(:download))
        assert(item.shipping?)
        refute(item.download?)
      end
    end
  end
end
