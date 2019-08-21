require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class OrderTest < TestCase
        def test_items
          order = Workarea::Order.new
          shippings = []
          discountable = order.items.build(discountable: true)
          not_discountable = order.items.build(discountable: false)
          on_sale = order.items.build.tap do |item|
            item.price_adjustments.build(data: { 'on_sale' => true })
          end
          excluded_product = order.items.build(product_id: 'FOOBAR')
          excluded_category = order.items.build(category_ids: %w(CAT1))

          discount_order = Discount::Order.new(order)
          assert(discount_order.allow_sale_items?)
          assert_includes(discount_order.items, discountable)
          refute_includes(discount_order.items, not_discountable)

          discount = Discount.new(allow_sale_items: true)
          discount_order = Discount::Order.new(order, shippings, discount)

          assert(discount_order.allow_sale_items?)
          assert_includes(discount_order.items, on_sale)
          assert_includes(discount_order.items, discountable)

          discount = Discount.new(allow_sale_items: false)
          discount_order = Discount::Order.new(order, shippings, discount)

          refute(discount_order.allow_sale_items?)
          refute_includes(discount_order.items, on_sale)
          assert_includes(discount_order.items, discountable)

          discount = Discount.new(excluded_product_ids: %w(FOOBAR))
          discount_order = Discount::Order.new(order, shippings, discount)

          refute_includes(discount_order.items, excluded_product)
          assert_includes(discount_order.items, excluded_category)
          assert_includes(discount_order.items, discountable)

          discount = Discount.new(excluded_category_ids: %w(CAT1))
          discount_order = Discount::Order.new(order, shippings, discount)

          refute_includes(discount_order.items, excluded_category)
          assert_includes(discount_order.items, excluded_product)
          assert_includes(discount_order.items, discountable)

          discount_order = Discount::Order.new(order, shippings)
          assert_includes(discount_order.items, excluded_product)
          assert_includes(discount_order.items, excluded_category)
          assert_includes(discount_order.items, discountable)
          assert_includes(discount_order.items, on_sale)
        end
      end
    end
  end
end
