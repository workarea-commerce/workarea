require 'test_helper'

module Workarea
  class InventoryAdjustmentTest < TestCase
    setup :set_inventory

    def order
      @order ||= create_order(
        items: [
          { product_id: 'PROD1', sku: 'SKU1', quantity: 1 },
          { product_id: 'PROD1', sku: 'SKU2', quantity: 2 },
          { product_id: 'PROD1', sku: 'SKU3', quantity: 3 }
        ]
      )
    end

    def set_inventory
      create_inventory(id: 'SKU1', available: 100, policy: 'standard')
      create_inventory(id: 'SKU2', available: 1, policy: 'standard')
      create_inventory(id: 'SKU3', available: 0, policy: 'standard')
    end

    def test_adjust
      adjustment = InventoryAdjustment.new(order).tap(&:perform)

      assert_equal(2, order.items.count)
      assert_equal(1, order.items[0].quantity)
      assert_equal(1, order.items[1].quantity)
      assert_nil(order.items.detect { |i| i.sku == 'SKU3' })

      assert_includes(
        adjustment.errors,
        I18n.t('workarea.errors.messages.sku_limited_quantity', quantity: 1, sku: 'SKU2')
      )
      assert_includes(
        adjustment.errors,
        I18n.t('workarea.errors.messages.sku_unavailable', sku: 'SKU3')
      )
    end
  end
end
