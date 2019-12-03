require 'test_helper'

module Workarea
  module Admin
    class FulfillmentViewModelTest < TestCase
      def test_pending_items_uses_pending_quantity
        order = create_placed_order
        fulfillment = Fulfillment.find(order.id)

        view_model = FulfillmentViewModel.wrap(fulfillment)
        assert_equal(2, view_model.pending_items.first.quantity)

        fulfillment.ship_items('1Z', [{ id: order.items.first.id, quantity: 1 }])
        view_model = FulfillmentViewModel.wrap(fulfillment.reload)
        assert_equal(1, view_model.pending_items.first.quantity)

        fulfillment.cancel_items([{ id: order.items.first.id, quantity: 1 }])
        view_model = FulfillmentViewModel.wrap(fulfillment.reload)
        assert(view_model.pending_items.blank?)
      end

      def test_cancellations_use_canceled_quantity
        order = create_placed_order
        fulfillment = Fulfillment.find(order.id)

        view_model = FulfillmentViewModel.wrap(fulfillment)
        assert(view_model.cancellations.blank?)

        fulfillment.ship_items('1Z', [{ id: order.items.first.id, quantity: 1 }])
        fulfillment.cancel_items([{ id: order.items.first.id, quantity: 1 }])

        view_model = FulfillmentViewModel.wrap(fulfillment.reload)
        assert_equal(1, view_model.cancellations.first.quantity)
      end
    end
  end
end
