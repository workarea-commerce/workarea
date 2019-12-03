require 'test_helper'

module Workarea
  class Fulfillment
    class ItemTest < TestCase
      setup :set_fulfillment_item

      def set_fulfillment_item
        @item = Fulfillment.create!(items: [{ quantity: 3 }]).items.first
      end

      def test_quantity_pending
        @item.events.create!(status: 'shipped', quantity: 1)
        @item.events.create!(status: 'canceled', quantity: 1)

        assert_equal(1, @item.quantity_pending)

        @item.events.create!(status: 'shipped', quantity: 2)
        @item.reload
        assert_equal(0, @item.quantity_pending)
      end

      def test_quantity_shipped
        @item.events.create!(status: 'shipped', quantity: 2)
        @item.events.create!(status: 'canceled', quantity: 1)

        assert_equal(2, @item.quantity_shipped)
      end

      def test_quantity_canceled
        @item.events.create!(status: 'shipped', quantity: 1)
        @item.events.create!(status: 'canceled', quantity: 2)

        assert_equal(2, @item.quantity_canceled)
      end
    end
  end
end
