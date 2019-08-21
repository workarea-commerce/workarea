require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class OrderTotalTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes

        def qualified_discount
          @qualified_discount ||=
            OrderTotal.new(amount_type: 'percent', amount: 10)
        end
        alias_method :order_total_discount, :qualified_discount
        alias_method :promo_codes_discount, :qualified_discount

        def discounted_order
          @discounted_order ||= Workarea::Order.new
        end

        def test_apply
          order = Workarea::Order.new(subtotal_price: 12.to_m)

          item = order.items.build(product_id: 'PRODUCT', sku: 'SKU1')
          item.price_adjustments.build(price: 'item', amount: 6.to_m)

          item = order.items.build(product_id: 'PRODUCT', sku: 'SKU2', quantity: 2)
          item.price_adjustments.build(price: 'item', amount: 6.to_m, quantity: 2)

          discount = OrderTotal.new(amount_type: 'percent', amount: 10)
          discount.apply(order)

          assert_equal(-0.6.to_m, order.items.first.price_adjustments.last.amount)
          assert_equal(-0.6.to_m, order.items.second.price_adjustments.last.amount)

          order = Workarea::Order.new(subtotal_price: 111.to_m)

          item = order.items.build(
            product_id: 'PRODUCT',
            sku: 'SKU1',
            quantity: 3
          )
          item.price_adjustments.build(price: 'item', amount: 96.60.to_m, quantity: 3)

          item = order.items.build(product_id: 'PRODUCT', sku: 'SKU2', quantity: 2)
          item.price_adjustments.build(price: 'item', amount: 14.40.to_m, quantity: 2)

          discount = OrderTotal.new(amount_type: 'flat', amount: 5)
          discount.apply(order)

          OrderTotals.new(order).total

          assert_equal(-4.35.to_m, order.items.first.price_adjustments.last.amount)
          assert_equal(-0.65.to_m, order.items.second.price_adjustments.last.amount)
          assert_equal(106.to_m, order.total_price)
        end
      end
    end
  end
end
