require 'test_helper'

module Workarea
  module Admin
    class ShippingViewModelTest < TestCase
      def test_items
        order = create_order(
          items: [
            { product_id: 'PRODUCT', sku: 'SKU1', quantity: 1 },
            { product_id: 'PRODUCT', sku: 'SKU2', quantity: 2 }
          ]
        )

        shipping = create_shipping(
          order_id: order.id,
          quantities: { order.items.second.id => 1 }
        )

        view_model = ShippingViewModel.wrap(shipping)

        assert_equal(1, view_model.items.size)
        assert(view_model.items.first.is_a?(OrderItemViewModel))
        assert_equal('PRODUCT', view_model.items.first.product_id)
        assert_equal('SKU2', view_model.items.first.sku)
        assert_equal(1, view_model.items.first.quantity)
      end
    end
  end
end
