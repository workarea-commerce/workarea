require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class QuantityFixedPriceTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes

        def qualified_discount
          @qualified_discount ||= QuantityFixedPrice.new(
            quantity: 2,
            price: 10,
            product_ids: ['PRODUCT']
          )
        end
        alias_method :order_total_discount, :qualified_discount
        alias_method :promo_codes_discount, :qualified_discount

        def discounted_order
          @discounted_order ||= Workarea::Order.new.tap do |order|
            order.items.build(product_id: 'PRODUCT', quantity: 2)
          end
        end

        def test_qualifies?
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 10,
            product_ids: ['PRODUCT1']
          )

          refute(discount.qualifies?(order))

          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)
          order.items.first.category_ids = ['CATEGORY']

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 10,
            product_ids: ['PRODUCT1'],
            category_ids: ['CATEGORY']
          )

          assert(discount.qualifies?(order))
        end

        def test_apply
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', quantity: 2)
          item = order.items.first
          item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 12.to_m
          )

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 5,
            product_ids: ['PRODUCT1']
          )

          discount.apply(order)
          OrderTotals.new(order).total

          assert_equal(2, item.price_adjustments.length)
          assert_equal(-7.to_m, item.price_adjustments.last.amount)
          assert_equal(5.to_m, order.total_price)
        end

        def test_apply_multiple_applications
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', quantity: 5)
          item = order.items.first
          item.price_adjustments.build(
            price: 'item',
            quantity: 5,
            amount: 30.to_m
          )

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 5,
            product_ids: ['PRODUCT1']
          )

          discount.apply(order)
          OrderTotals.new(order).total

          assert_equal(2, item.price_adjustments.length)
          assert_equal(-14.to_m, item.price_adjustments.last.amount)
          assert_equal(16.to_m, order.total_price)
        end

        def test_apply_across_items
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', quantity: 1)
          order.add_item(product_id: 'PRODUCT2', sku: 'SKU2', quantity: 1)

          first_item = order.items.first
          first_item.price_adjustments.build(
            price: 'item',
            quantity: 1,
            amount: 6.to_m
          )

          second_item = order.items.last
          second_item.price_adjustments.build(
            price: 'item',
            quantity: 1,
            amount: 7.to_m
          )

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 5,
            product_ids: ['PRODUCT1', 'PRODUCT2']
          )

          discount.apply(order)
          OrderTotals.new(order).total

          assert_equal(2, first_item.price_adjustments.length)
          assert_equal(-3.69.to_m, first_item.price_adjustments.last.amount)

          assert_equal(2, second_item.price_adjustments.length)
          assert_equal(-4.31.to_m, second_item.price_adjustments.last.amount)

          assert_equal(5.to_m, order.total_price)
        end

        def test_apply_multiple_applications_across_items
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', quantity: 2)
          order.add_item(product_id: 'PRODUCT2', sku: 'SKU2', quantity: 3)

          first_item = order.items.first
          first_item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 12.to_m
          )

          second_item = order.items.last
          second_item.price_adjustments.build(
            price: 'item',
            quantity: 3,
            amount: 21.to_m
          )

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 5,
            product_ids: ['PRODUCT1', 'PRODUCT2']
          )

          discount.apply(order)
          OrderTotals.new(order).total

          assert_equal(2, first_item.price_adjustments.length)
          assert_equal(-3.69.to_m, first_item.price_adjustments.last.amount)

          assert_equal(2, second_item.price_adjustments.length)
          assert_equal(-13.31.to_m, second_item.price_adjustments.last.amount)

          assert_equal(16.to_m, order.total_price)
        end

        def test_apply_to_appropriate_quantity_item
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', quantity: 2)
          order.add_item(product_id: 'PRODUCT2', sku: 'SKU2', quantity: 1)

          first_item = order.items.first
          first_item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 12.to_m
          )

          second_item = order.items.last
          second_item.price_adjustments.build(
            price: 'item',
            quantity: 1,
            amount: 7.to_m
          )

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 5,
            product_ids: ['PRODUCT1', 'PRODUCT2']
          )

          discount.apply(order)
          OrderTotals.new(order).total

          assert_equal(2, first_item.price_adjustments.length)
          assert_equal(-3.69.to_m, first_item.price_adjustments.last.amount)

          assert_equal(2, second_item.price_adjustments.length)
          assert_equal(-4.31.to_m, second_item.price_adjustments.last.amount)

          assert_equal(11.to_m, order.total_price)
        end

        def test_apply_across_three_items
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', quantity: 2)
          order.add_item(product_id: 'PRODUCT2', sku: 'SKU2', quantity: 2)
          order.add_item(product_id: 'PRODUCT3', sku: 'SKU3', quantity: 2)

          first_item = order.items[0]
          first_item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 12.to_m
          )

          second_item = order.items[1]
          second_item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 14.to_m
          )

          third_item = order.items[2]
          third_item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 14.to_m
          )

          discount = QuantityFixedPrice.new(
            quantity: 2,
            price: 5,
            product_ids: ['PRODUCT1', 'PRODUCT2', 'PRODUCT3']
          )

          discount.apply(order)
          OrderTotals.new(order).total

          assert_equal(2, first_item.price_adjustments.length)
          assert_equal(-7.to_m, first_item.price_adjustments.last.amount)

          assert_equal(2, second_item.price_adjustments.length)
          assert_equal(-9.to_m, second_item.price_adjustments.last.amount)

          assert_equal(2, third_item.price_adjustments.length)
          assert_equal(-9.to_m, third_item.price_adjustments.last.amount)

          assert_equal(15.to_m, order.total_price)
        end

        def test_apply_with_quantity_of_three
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', quantity: 2)
          order.add_item(product_id: 'PRODUCT2', sku: 'SKU2', quantity: 2)

          first_item = order.items.first
          first_item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 32.to_m
          )

          second_item = order.items.last
          second_item.price_adjustments.build(
            price: 'item',
            quantity: 2,
            amount: 32.to_m
          )

          discount = QuantityFixedPrice.new(
            quantity: 3,
            price: 29,
            product_ids: ['PRODUCT1', 'PRODUCT2']
          )

          discount.apply(order)
          OrderTotals.new(order).total

          assert_equal(45.to_m, order.total_price)
        end
      end
    end
  end
end
