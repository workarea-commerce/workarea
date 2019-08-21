require 'test_helper'

module Workarea
  module Inventory
    module Policies
      class StandardTest < TestCase
        def test_available_to_sell
          sku = create_inventory(available: 5, reserve: 3)

          policy = Standard.new(sku)
          assert_equal(2, policy.available_to_sell)

          sku.update_attributes(available: 1)
          assert_equal(0, policy.available_to_sell)
        end
      end
    end
  end
end
