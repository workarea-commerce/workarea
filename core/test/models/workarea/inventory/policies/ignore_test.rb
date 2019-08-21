require 'test_helper'

module Workarea
  module Inventory
    module Policies
      class IgnoreTest < TestCase
        def test_purchase
          sku = create_inventory(available: 1, backordered: 1, purchased: 0)

          policy = Ignore.new(sku)
          policy.purchase(5)

          sku.reload
          assert_equal(1, sku.available)
          assert_equal(1, sku.backordered)
          assert_equal(5, sku.purchased)
        end
      end
    end
  end
end
