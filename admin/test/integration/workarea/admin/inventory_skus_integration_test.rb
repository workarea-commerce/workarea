require 'test_helper'

module Workarea
  module Admin
    class InventorySkusIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_can_create_an_inventory_sku
        post admin.inventory_skus_path,
          params: {
            sku: {
              id:                'SKU1',
              policy:            'standard',
              available:         '10',
              backordered:       '5',
              backordered_until: '2013/05/22',
              reserve:           '2'
            }
          }

        assert_equal(1, Inventory::Sku.count)

        sku = Inventory::Sku.first
        assert_equal('SKU1', sku.id)
        assert_equal('standard', sku.policy)
        assert_equal(10, sku.available)
        assert_equal(5, sku.backordered)
        assert_equal(Time.zone.parse('2013/05/22'), sku.backordered_until)
        assert_equal(2, sku.reserve)
      end

      def test_can_update_a_pricing_sku
        post admin.inventory_skus_path,
          params: {
            sku: {
              id:                'SKU1',
              policy:            'standard',
              available:         '10',
              backordered:       '5',
              backordered_until: '2013/05/22',
              reserve:           '2'
            }
          }

        patch admin.inventory_sku_path('SKU1'),
          params: {
            sku: {
              policy:            'allow_backorder',
              available:         '11',
              backordered:       '6',
              backordered_until: '2013/05/23',
              reserve:           '3'
            }
          }

        assert_equal(1, Inventory::Sku.count)

        sku = Inventory::Sku.first
        assert_equal('SKU1', sku.id)
        assert_equal('allow_backorder', sku.policy)
        assert_equal(11, sku.available)
        assert_equal(6, sku.backordered)
        assert_equal(Time.zone.parse('2013/05/23'), sku.backordered_until)
        assert_equal(3, sku.reserve)
      end
    end
  end
end
