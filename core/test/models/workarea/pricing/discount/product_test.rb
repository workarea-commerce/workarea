require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class ProductTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes
        include DiscountConditionTests::ItemQuantity

        def qualified_discount
          @item_quantity_discount ||= Product.new(product_ids: ['PRODUCT'])
        end
        alias_method :order_total_discount, :qualified_discount
        alias_method :promo_codes_discount, :qualified_discount
        alias_method :item_quantity_discount, :qualified_discount

        def discounted_order
          @discounted_order ||= Workarea::Order.new.tap do |order|
            order.items.build(product_id: 'PRODUCT')
          end
        end

        def test_item_qualifies
          order = Workarea::Order.new
          item = order.items.build(product_id: 'PRODUCT')

          discount = Product.new(product_ids: ['PRODUCT1'])
          refute(discount.item_qualifies?(item))

          discount = Product.new(product_ids: ['PRODUCT'])
          assert(discount.item_qualifies?(item))
        end

        def test_apply
          order = Workarea::Order.new

          item = order.items.build(product_id: 'PRODUCT1', sku: 'SKU1')
          item.price_adjustments.build(price: 'item', amount: 6.to_m)

          item = order.items.build(
            product_id: 'PRODUCT2',
            sku: 'SKU2',
            quantity: 2
          )
          item.price_adjustments.build(price: 'item', amount: 6.to_m)

            discount = Product.new(
              amount_type: 'percent',
              amount: 50,
              product_ids: ['PRODUCT1']
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
