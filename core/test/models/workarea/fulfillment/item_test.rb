require 'test_helper'

module Workarea
  class Fulfillment
    class ItemTest < TestCase
      def test_quantity_pending
        item = Item.new(quantity: 3)
        item.events.build(status: 'shipped', quantity: 1)
        item.events.build(status: 'canceled', quantity: 1)

        assert_equal(1, item.quantity_pending)

        item.events.build(status: 'shipped', quantity: 2)
        assert_equal(0, item.quantity_pending)
      end

      def test_quantity_shipped
        item = Item.new(quantity: 3)
        item.events.build(status: 'shipped', quantity: 2)
        item.events.build(status: 'canceled', quantity: 1)

        assert_equal(2, item.quantity_shipped)
      end

      def test_quantity_canceled
        item = Item.new(quantity: 3)
        item.events.build(status: 'shipped', quantity: 1)
        item.events.build(status: 'canceled', quantity: 2)

        assert_equal(2, item.quantity_canceled)
    end
    end
  end
end
