require 'test_helper'

module Workarea
  module Pricing
    module Calculators
      class DiscountCalculatorTest < TestCase
        def test_adjust
          order = Order.new
          order.items.build(product_id: 'PRODUCT', sku: 'SKU', quantity: 1)
          order.items.first.adjust_pricing(price: 'item', amount: 5.to_m)
          order.items.first.adjust_pricing(
            price: 'item',
            amount: -6.to_m,
            data: { 'discount_id' => 'foo' }
          )

          shipping = Shipping.new
          shipping.set_shipping_service(
            id: 'GROUND',
            name: 'Ground',
            tax_code: '001',
            base_price: 3.to_m
          )
          shipping.adjust_pricing(
            price: 'shipping',
            amount: -6.to_m,
            data: { 'discount_id' => 'foo' }
          )

          DiscountCalculator.test_adjust(order, shipping)

          assert_equal(2, order.items.first.price_adjustments.length)
          assert_equal(-5.to_m, order.items.first.price_adjustments.last.amount)
          assert_equal(2, shipping.price_adjustments.length)
          assert_equal(-3.to_m, shipping.price_adjustments.last.amount)
        end

        def test_most_valuable_group
          create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

          order = create_order
          order.add_item(product_id: 'PRODUCT', sku: 'SKU')

          discount_1 = create_order_total_discount(
            name: 'Discount',
            amount_type: 'flat',
            amount: 1
          )

          discount_2 = create_order_total_discount(
            name: 'Discount',
            amount_type: 'flat',
            amount: 2
          )

          discount_3 = create_order_total_discount(
            name: 'Discount',
            amount_type: 'flat',
            amount: 3
          )

          request = Calculator::TestRequest.new(order, [])
          calculator = DiscountCalculator.new(request)

          assert_equal([discount_3], calculator.most_valuable_group.discounts)
        end

        def test_adjust_with_product_exclusions
          category = create_category
          discount = create_category_discount(
            category_ids: [category.id],
            order_total: 9.99.to_m,
            excluded_product_ids: %w(PRODUCT2),
            amount_type: :percent,
            amount: 50
          )

          order = Order.new
          item_one = order.items.build(
            product_id: 'PRODUCT',
            sku: 'SKU',
            quantity: 1,
            category_ids: [category.id]
          )
          item_one.adjust_pricing(price: 'item', amount: 5.to_m)

          item_two = order.items.build(
            product_id: 'PRODUCT2',
            sku: 'SKU2',
            quantity: 1,
            category_ids: [category.id]
          )
          item_two.adjust_pricing(price: 'item', amount: 5.to_m)

          DiscountCalculator.test_adjust(order)

          assert_equal(1, item_one.price_adjustments.length)
          assert_equal(1, item_two.price_adjustments.length)

          item_one.quantity = 2
          item_one.price_adjustments.first.assign_attributes(
            amount: 10.to_m,
            quantity: 2
          )

          DiscountCalculator.test_adjust(order)

          assert_equal(2, item_one.price_adjustments.length)
          assert_equal(-5.to_m, item_one.price_adjustments.last.amount)
          assert_equal(1, item_two.price_adjustments.length)
        end

        def test_adjust_with_category_exclusions
          discount = create_order_total_discount(
            excluded_category_ids: %w(TESTCAT),
            order_total: 9.99.to_m
          )

          order = Order.new
          item_one = order.items.build(
            product_id: 'PRODUCT',
            sku: 'SKU',
            quantity: 1,
          )
          item_one.adjust_pricing(price: 'item', amount: 5.to_m)

          item_two = order.items.build(
            product_id: 'PRODUCT2',
            sku: 'SKU2',
            quantity: 1,
            category_ids: %w(TESTCAT)
          )
          item_two.adjust_pricing(price: 'item', amount: 5.to_m)

          DiscountCalculator.test_adjust(order)

          assert_equal(1, item_one.price_adjustments.length)
          assert_equal(1, item_two.price_adjustments.length)

          item_one.quantity = 2
          item_one.price_adjustments.first.amount = 10.to_m

          DiscountCalculator.test_adjust(order)

          assert_equal(2, item_one.price_adjustments.length)
          assert_equal(-1.to_m, item_one.price_adjustments.last.amount)
          assert_equal(1, item_two.price_adjustments.length)
        end
      end
    end
  end
end
