require 'test_helper'

module Workarea
  class AddMultipleCartItems
    class ItemTest < TestCase
      setup :products

      def products
        @products ||= [
          create_product(
            id: 'PROD1',
            variants: [{ sku: 'SKU1', regular: 5.00 }]
          ),
          create_product(
            id: 'PROD2',
            variants: [{ sku: 'SKU2', regular: 10.00 }]
          )
        ]
      end

      def test_save
        order = create_order
        params = { sku: 'sku2', quantity: 1 }
        item = AddMultipleCartItems::Item.new(order, params)

        assert(item.valid?)
        assert(item.save)
        assert(item.persisted?)

        item = item.item
        assert(item.persisted?)
        assert_equal('PROD2', item.product_id)
        assert_equal('SKU2', item.sku)
        assert_equal(1, item.quantity)

        order.reload
        assert_equal(1, order.items.count)

        params = { sku: 'SKU3', quantity: 2 }
        item = AddMultipleCartItems::Item.new(order, params)

        refute(item.save)
        refute(item.persisted?)
        refute(item.item.present?)

        assert_equal(
          t('workarea.add_multiple_cart_items.errors.missing_product'),
          item.errors.full_messages.first
        )

        order.reload
        assert_equal(1, order.items.count)
      end
    end
  end
end
