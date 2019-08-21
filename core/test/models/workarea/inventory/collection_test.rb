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
    end
  end
end
