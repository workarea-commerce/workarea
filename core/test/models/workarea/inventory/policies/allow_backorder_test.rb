require 'test_helper'

module Workarea
  module Inventory
    module Policies
      class AllowBackorderTest < TestCase
        def test_available_to_sell
          sku = create_inventory(available: 5, reserve: 3)

          policy = AllowBackorder.new(sku)
          assert_equal(2, policy.available_to_sell)

          sku.update_attributes(backordered: 5)
          assert_equal(7, policy.available_to_sell)

          sku.update_attributes(available: 1, backordered: 2)
          assert_equal(0, policy.available_to_sell)
        end

        def test_purchase
          sku = create_inventory(
            id: 'SKU1',
            policy: 'allow_backorder',
            available: 5,
            backordered: 3
          )

          policy = AllowBackorder.new(sku)
          policy.purchase(3)

          sku.reload
          assert_equal(2, sku.available)
          assert_equal(3, sku.backordered)


          sku = create_inventory(
            id: 'SKU2',
            policy: 'allow_backorder',
            available: 5,
            backordered: 3
          )

          policy = AllowBackorder.new(sku)
          policy.purchase(7)

          sku.reload

          assert_equal(0, sku.available)
          assert_equal(1, sku.backordered)


          sku = create_inventory(
            id: 'SKU3',
            policy: 'allow_backorder',
            available: 0,
            backordered: 3
          )

          policy = AllowBackorder.new(sku)
          policy.purchase(2)

          sku.reload

          assert_equal(0, sku.available)
          assert_equal(1, sku.backordered)
        end
      end
    end
  end
end
