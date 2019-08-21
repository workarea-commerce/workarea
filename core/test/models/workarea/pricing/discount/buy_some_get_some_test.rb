require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class BuySomeGetSomeTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes

        def qualified_discount
          @qualified_discount ||= BuySomeGetSome.new(
            purchase_quantity: 1,
            apply_quantity: 1,
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

        def create_discount_order(quantity, unit_price)
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU1', quantity: quantity)
          item = order.items.first
          item.price_adjustments.build(
            price: 'item',
            quantity: quantity,
            amount: unit_price * quantity
          )
          return order, item
        end

        def test_qualifies?
          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 1)

          refute(qualified_discount.qualifies?(order))

          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU1', quantity: 1)
          order.add_item(product_id: 'PRODUCT', sku: 'SKU2', quantity: 1)
          order.add_item(product_id: 'PRODUCT', sku: 'SKU3', quantity: 1)

          discount = BuySomeGetSome.new(
            purchase_quantity: 2,
            apply_quantity: 1,
            product_ids: ['PRODUCT']
          )

          assert(discount.qualifies?(order))

          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)

          discount = BuySomeGetSome.new(
            purchase_quantity: 1,
            apply_quantity: 1,
            product_ids: ['PRODUCT1']
          )

          refute(discount.qualifies?(order))

          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)
          order.items.first.category_ids = ['CATEGORY']

          discount = BuySomeGetSome.new(
            purchase_quantity: 1,
            apply_quantity: 1,
            product_ids: ['PRODUCT1'],
            category_ids: ['CATEGORY']
          )

          assert(discount.qualifies?(order))
        end

        def test_apply
          order, item = *create_discount_order(2, 6.to_m)
          discount = BuySomeGetSome.new(
            purchase_quantity: 1,
            apply_quantity: 1,
            percent_off: 100,
            product_ids: ['PRODUCT']
          )

          discount.apply(order)
          assert_equal(-6.to_m, item.price_adjustments.last.amount)

          order, item = *create_discount_order(4, 6.to_m)
          discount = BuySomeGetSome.new(
            purchase_quantity: 1,
            apply_quantity: 1,
            percent_off: 100,
            product_ids: ['PRODUCT']
          )

          discount.apply(order)
          assert_equal(-12.to_m, item.price_adjustments.last.amount)

          order, item = *create_discount_order(4, 6.to_m)
          discount = BuySomeGetSome.new(
            purchase_quantity: 1,
            apply_quantity: 1,
            percent_off: 100,
            max_applications: 1,
            product_ids: ['PRODUCT']
          )

          discount.apply(order)
          assert_equal(-6.to_m, item.price_adjustments.last.amount)

          order, item = *create_discount_order(5, 6.to_m)
          discount = BuySomeGetSome.new(
            purchase_quantity: 3,
            apply_quantity: 1,
            percent_off: 50,
            product_ids: ['PRODUCT']
          )

          discount.apply(order)
          assert_equal(-3.to_m, item.price_adjustments.last.amount)

          order, item = *create_discount_order(9, 6.to_m)
          discount = BuySomeGetSome.new(
            purchase_quantity: 3,
            apply_quantity: 1,
            percent_off: 50,
            max_applications: 2,
            product_ids: ['PRODUCT']
          )

          discount.apply(order)
          assert_equal(-6.to_m, item.price_adjustments.last.amount)

          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU1', quantity: 2)
          order.add_item(product_id: 'PRODUCT', sku: 'SKU2', quantity: 3)
          order.add_item(product_id: 'PRODUCT', sku: 'SKU3', quantity: 1)

          item_1 = order.items.first
          item_2 = order.items.second
          item_3 = order.items.third

          item_1.price_adjustments.build(price: 'item', quantity: 2, amount: 20.to_m)
          item_2.price_adjustments.build(price: 'item', quantity: 3, amount: 15.to_m)
          item_3.price_adjustments.build(price: 'item', quantity: 1, amount: 15.to_m)

          discount = BuySomeGetSome.new(
            purchase_quantity: 2,
            apply_quantity: 1,
            percent_off: 50,
            product_ids: ['PRODUCT']
          )

          discount.apply(order)

          assert_equal(-5.to_m, item_1.price_adjustments.last.amount)
          assert_equal(1, item_1.price_adjustments.last.quantity)
          assert_equal(1, item_2.price_adjustments.length)
          assert_equal(-7.5.to_m, item_3.price_adjustments.last.amount)
          assert_equal(1, item_3.price_adjustments.last.quantity)
        end

        def test_combining_with_order_discounts
          create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

          buy_2_get_1 = create_buy_some_get_some_discount(
            name: 'Test Discount',
            purchase_quantity: 2,
            apply_quantity: 1,
            percent_off: 100,
            product_ids: ['PRODUCT']
          )

          create_order_total_discount(
            name: 'Discount',
            amount_type: 'flat',
            amount: 2,
            compatible_discount_ids: [buy_2_get_1.id]
          )

          order = Workarea::Order.new
          order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 3)

          Pricing.perform(order)

          assert_equal(8.to_m, order.items.first.total_value)
          assert_equal(10.to_m, order.subtotal_price)
          assert_equal(8.to_m, order.total_value)
          assert_equal(8.to_m, order.total_price)
        end
      end
    end
  end
end
