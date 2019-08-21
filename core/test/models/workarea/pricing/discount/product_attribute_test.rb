require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class ProductAttributeTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes
        include DiscountConditionTests::ItemQuantity

        def qualified_discount
          @item_quantity_discount ||= ProductAttribute.new(
            attribute_name: 'foo',
            attribute_value: 'bar'
          )
        end
        alias_method :order_total_discount, :qualified_discount
        alias_method :promo_codes_discount, :qualified_discount
        alias_method :item_quantity_discount, :qualified_discount

        def discounted_order
          @discounted_order ||= Workarea::Order.new.tap do |order|
            order.items.build(
              product_attributes: { 'details' => { 'en' => { 'foo' => 'bar' } } }
            )
          end
        end

        def test_item_qualifies
          order = Workarea::Order.new
          item = order.items.build(
            product_attributes: { 'details' => { 'en' => { 'foo' => 'bar' } } }
          )

          discount = ProductAttribute.new(
            attribute_name: 'foo',
            attribute_value: 'baz'
          )
          refute(discount.item_qualifies?(item))

          discount = ProductAttribute.new(
            attribute_name: 'foo',
            attribute_value: 'bar'
          )
          assert(discount.item_qualifies?(item))

          item.product_attributes = { 'details' => { 'en' => { 'foo' => 'bar' } } }
          assert(discount.item_qualifies?(item))
        end

        def test_apply
          order = Workarea::Order.new

          item = order.items.build(product_id: 'PRODUCT', sku: 'SKU1')
          item.product_attributes = { 'details' => { 'en' => { 'foo' => 'bar' } } }
          item.price_adjustments.build(price: 'item', amount: 6.to_m)

          item = order.items.build(
            product_id: 'PRODUCT',
            sku: 'SKU2',
            quantity: 2
          )
          item.price_adjustments.build(price: 'item', amount: 6.to_m)

          discount = ProductAttribute.new(
            amount_type: 'percent',
            amount: 50,
            attribute_name: 'foo',
            attribute_value: 'bar'
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
