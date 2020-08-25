require 'test_helper'

module Workarea
  class Fulfillment
    module Policies
      class DownloadTest < TestCase
        def test_process
          order = Order.new(user_id: '1234')
          item = order.items.build(sku: 'SKU1')

          fulfillment = Fulfillment.new(
            id: order.id,
            items: [{ order_item_id: item.id.to_s, quantity: 1 }]
          )

          sku = create_fulfillment_sku(
            id: 'SKU1',
            policy: 'download',
            file: product_image_file_path
          )

          policy = Policies::Download.new(sku)
          policy.process(order_item: item, fulfillment: fulfillment)

          assert_equal(1, Fulfillment::Token.count)

          token = Fulfillment::Token.first
          assert_equal(order.id.to_s, token.order_id)
          assert_equal(item.id.to_s, token.order_item_id)
          assert_equal(sku.id, token.sku)

          assert_equal(1, fulfillment.items.first.events.size)
          assert_equal('shipped', fulfillment.items.first.events.first.status)
          assert_equal(1, fulfillment.items.first.events.first.quantity)
        end
      end
    end
  end
end
