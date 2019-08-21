require 'test_helper'

module Workarea
  module Admin
    class FulfillmentItemViewModelTest < Workarea::TestCase
      def test_quantity_returns_from_option
        view_model = FulfillmentItemViewModel.new(mock, quantity: 5)
        assert_equal(5, view_model.quantity)
      end

      def test_quantity_sums_from_events
        item = Fulfillment::Item.new(events: [{ quantity: 2 }, { quantity: 3 }])
        view_model = FulfillmentItemViewModel.new(mock, events: item.events)
        assert_equal(5, view_model.quantity)
      end
    end
  end
end
