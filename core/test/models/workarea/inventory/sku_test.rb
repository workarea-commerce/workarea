require 'test_helper'

module Workarea
  module Inventory
    class SkuTest < TestCase
      def test_backordered?
        sku = Sku.new(available: 1)
        refute(sku.backordered?)

        sku.available = 0
        refute(sku.backordered?)

        sku.backordered = 2
        refute(sku.backordered?)

        sku.policy = 'allow_backorder'
        assert(sku.backordered?)
      end

      def test_purchasable?
        sku = create_inventory(policy: 'ignore', available: 0)
        assert(sku.purchasable?(1))


        sku = create_inventory(id: 'SKU2', policy: 'standard', available: 1)

        assert(sku.purchasable?(1))
        refute(sku.purchasable?(2))

        sku.reserve = 3
        refute(sku.purchasable?(1))

        sku = create_inventory(id: 'SKU3', policy: 'allow_backorder', available: 1)
        assert(sku.purchasable?(1))

        sku.backordered = 1
        assert(sku.purchasable?(2))
        refute(sku.purchasable?(3))

        sku = create_inventory(
          id: 'SKU4',
          policy: 'allow_backorder',
          available: 0,
          backordered: 2,
          reserve: 1
        )
        assert(sku.purchasable?)

        sku.reserve = 2
        refute(sku.purchasable?)
      end

      def test_insufficiency_for
        sku = create_inventory(id: 'SKU2', policy: 'ignore')
        assert_equal(0, sku.insufficiency_for(9_999))

        sku = create_inventory(id: 'SKU3', policy: 'standard', available: 1)
        assert_equal(0, sku.insufficiency_for(1))
        assert_equal(1, sku.insufficiency_for(2))

        sku.reserve = 2
        assert_equal(2, sku.insufficiency_for(2))

        sku = create_inventory(id: 'SKU4', policy: 'allow_backorder', available: 1, backordered: 1)
        assert_equal(0, sku.insufficiency_for(1))
        assert_equal(0, sku.insufficiency_for(2))
        assert_equal(1, sku.insufficiency_for(3))

        sku = create_inventory(id: 'SKU5', reserve: 2, available: 1)
        assert_equal(2, sku.insufficiency_for(2))
      end

      def test_capture
        sku = create_inventory(id: 'SKU1', policy: 'standard', available: 1)
        assert_raises(InsufficientError) { sku.capture(2) }
      end

      def test_release
        sku = create_inventory(
          id: 'SKU1',
          available: 1,
          backordered: 2,
          purchased: 2,
          policy: 'allow_backorder'
        )

        sku.release(1, 1)
        sku.reload

        assert_equal(2, sku.available)
        assert_equal(3, sku.backordered)
        assert_equal(5, sku.sellable)
        assert_equal(0, sku.purchased)
      end
    end
  end
end
