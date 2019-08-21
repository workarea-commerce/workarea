require 'test_helper'

module Workarea
  module Storefront
    class InventoryStatusViewModelTest < TestCase
      def test_message
        inventory = create_inventory(
          id: 'SKU',
          policy: 'standard',
          available: 10,
          backordered: 10
        )

        view_model = InventoryStatusViewModel.new(inventory)
        assert_equal('In Stock', view_model.message)

        inventory.available = 2
        assert_equal('Only 2 Left', view_model.message)

        inventory.policy = 'allow_backorder'
        inventory.available = 0
        inventory.backordered_until = Date.new(2014, 12, 10)
        assert_equal('Ships on 10 Dec', view_model.message)

        inventory.backordered_until = nil
        assert_equal('Backordered', view_model.message)

        inventory.policy = 'standard'
        assert_equal('Out of Stock', view_model.message)

        inventory.policy = 'allow_backorder'
        inventory.available = 0
        inventory.backordered = 0
        inventory.backordered_until = Date.new(2017, 12, 10)
        assert_equal('Out of Stock', view_model.message)
      end
    end
  end
end
