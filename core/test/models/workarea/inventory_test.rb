require 'test_helper'

module Workarea
  class InventoryTest < TestCase
    def test_finds_total_sales_for_one_sku
      create_inventory(id: 'SKU1', purchased: 7)
      assert_equal(7, Inventory.total_sales('SKU1'))
    end

    def test_finds_total_sales_for_a_set_of_skus
      create_inventory(id: 'SKU1', purchased: 7)
      create_inventory(id: 'SKU2', purchased: 5)

      assert_equal(12, Inventory.total_sales('SKU1', 'SKU2', 'SKU3'))
    end

    def test_any_available
      assert(Inventory.any_available?('SKU1'))
      assert(Inventory.any_available?('SKU1','SKU2','SKU3'))

      create_inventory(id: 'SKU1', policy: 'standard', available: 0)
      create_inventory(id: 'SKU2', policy: 'standard', available: 0)

      refute(Inventory.any_available?('SKU1'))
      refute(Inventory.any_available?('SKU1','SKU2'))
      assert(Inventory.any_available?('SKU1','SKU2','SKU3'))
    end
  end
end
