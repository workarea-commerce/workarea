require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class CategoryTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes
        include DiscountConditionTests::ItemQuantity

        def qualified_discount
          @item_quantity_discount ||= Category.new(category_ids: ['CATEGORY'])
        end
        alias_method :order_total_discount, :qualified_discount
        alias_method :promo_codes_discount, :qualified_discount
        alias_method :item_quantity_discount, :qualified_discount

        def discounted_order
          @discounted_order ||= Workarea::Order.new.tap do |order|
            order.items.build(category_ids: ['CATEGORY'])
          end
        end

        def test_item_qualifies?
          order = Workarea::Order.new
          item = order.items.build(category_ids: ['CATEGORY'])

          discount = Category.new(category_ids: ['CATEGORY1'])
          refute(discount.item_qualifies?(item))

          discount = Category.new(category_ids: ['CATEGORY'])
          assert(discount.item_qualifies?(item))
        end

        def test_apply
          order = Workarea::Order.new

          item = order.items.build(
            category_ids: ['CATEGORY1'],
            product_id: 'PRODUCT1',
            sku: 'SKU1'
          )
          item.price_adjustments.build(price: 'item', amount: 6.to_m)

          item = order.items.build(
            category_ids: ['CATEGORY2'],
            product_id: 'PRODUCT2',
            sku: 'SKU2',
            quantity: 2
          )
          item.price_adjustments.build(price: 'item', amount: 6.to_m)

          discount = Category.new(
            amount_type: 'percent',
            amount: 50,
            category_ids: ['CATEGORY1']
          )

          discount.apply(order)

          assert_equal(2, order.items.first.price_adjustments.length)
          assert_equal(-3.to_m, order.items.first.price_adjustments.last.amount)
          assert_equal(1, order.items.second.price_adjustments.length)
        end
      end
    end
  end
end
