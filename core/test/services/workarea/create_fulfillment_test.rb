require 'test_helper'

module Workarea
  class CreateFulfillmentTest < Workarea::TestCase
    setup do
      @order = create_order
    end

    def test_creating_items_per_order_item
      @order.add_item(product_id: '1', sku: 'SKU1')
      @order.add_item(product_id: '2', sku: 'SKU2', quantity: 2)

      CreateFulfillment.new(@order).perform

      fulfillment = Fulfillment.find(@order.id)
      assert_equal(fulfillment.items.count, 2)

      CreateFulfillment.new(@order).perform
      fulfillment.reload
      assert_equal(fulfillment.items.count, 2)
    end
  end
end
