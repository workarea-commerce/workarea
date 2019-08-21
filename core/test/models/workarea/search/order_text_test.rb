require 'test_helper'

module Workarea
  module Search
    class OrderTextTest < TestCase
      def test_discount_text
        shipping_discount = create_shipping_discount
        order_discount = create_order_total_discount
        product = create_product
        order = create_order
        order.add_item(
          product_id: product.id,
          sku: product.skus.first,
          quantity: 1
        )
        order.items.first.adjust_pricing(
          data: { 'discount_id' => order_discount.id.to_s }
        )
        order.save!

        shipping = create_shipping(order_id: order.id.to_s)
        shipping.adjust_pricing(
          data: { 'discount_id' => shipping_discount.id.to_s }
        )
        shipping.save!

        text = Search::OrderText.new(order)

        assert_includes(text.shippings, shipping)
        assert_includes(text.discount_text, order_discount.id.to_s)
        assert_includes(text.discount_text, shipping_discount.id.to_s)
      end
    end
  end
end
