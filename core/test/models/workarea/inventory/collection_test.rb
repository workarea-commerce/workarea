require 'test_helper'

module Workarea
  module Inventory
    class CollectionTest < TestCase
      setup :set_skus

      def set_skus
        @collection = Collection.new(%w(SKU1 SKU2 SKU3))
        Sku.create(id: 'SKU1', policy: 'standard', available: 10)
        Sku.create(id: 'SKU2', policy: 'standard', available: 9)
      end

      def test_returns_an_existing_record
        sku = @collection.for_sku('SKU1')

        assert_equal('SKU1', sku.id)
        assert_equal('standard', sku.policy)
        assert_equal(10, sku.available)
      end

      def test_returns_a_record_for_skus_missing_inventory
        sku = @collection.for_sku('SKU3')

        assert_equal('SKU3', sku.id)
        assert_equal('ignore', sku.policy)
      end

      def test_available_to_sell
        @collection = Collection.new(%w(SKU1 SKU2))
        assert_equal(19, @collection.available_to_sell)
      end

      def test_status
        inventory_one = Inventory::Sku.new(
          id: 'SKU1',
          policy: 'standard',
          available: 10,
          backordered: 10
        )

        inventory_two = Inventory::Sku.new(
          id: 'SK2',
          policy: 'standard',
          available: 5,
          backordered: 0
        )

        collection = Inventory::Collection.new(
          %w(SKU1 SKU2),
          [inventory_one, inventory_two]
        )

        assert_equal(:available, collection.status)

        inventory_one.available = 1
        assert_equal(:available, collection.status)

        inventory_two.available = 1
        assert_equal(:low_inventory, collection.status)

        inventory_one.policy = 'allow_backorder'
        inventory_one.available = 0
        assert_equal(:low_inventory, collection.status)

        inventory_two.available = 0
        assert_equal(:backordered, collection.status)

        inventory_one.policy = 'standard'
        assert_equal(:out_of_stock, collection.status)

        inventory_two.available = 10
        assert_equal(:available, collection.status)

        inventory_one.policy = 'allow_backorder'
        inventory_one.available = 0
        inventory_one.backordered = 0
        inventory_two.available = 0
        assert_equal(:out_of_stock, collection.status)
      end

      def test_status_with_single_sku
        inventory = Inventory::Sku.new(
          id: 'SKU',
          policy: 'standard',
          available: 10,
          backordered: 10
        )

        collection = Inventory::Collection.new(%w(SKU), [inventory])
        assert_equal(:available, collection.status)

        inventory.available = 2
        assert_equal(:low_inventory, collection.status)

        inventory.policy = 'allow_backorder'
        inventory.available = 0
        assert_equal(:backordered, collection.status)

        inventory.policy = 'standard'
        assert_equal(:out_of_stock, collection.status)

        inventory.policy = 'allow_backorder'
        inventory.available = 0
        inventory.backordered = 0
        assert_equal(:out_of_stock, collection.status)
      end
    end
  end
end
