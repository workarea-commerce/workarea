require 'test_helper'

module Workarea
  module Storefront
    class CartViewModelTest < TestCase
      setup :setup_view_model

      def setup_view_model
        @order = Order.new
        @view_model = CartViewModel.wrap(@order, action: 'show')
      end

      def test_items_has_the_newest_item_first
        @order.add_item(product_id: '123', sku: 'SKU1')
        @order.add_item(product_id: '123', sku: 'SKU2')
        assert_equal('SKU2', @view_model.items.first.sku)
      end

      def test_items_passes_options_to_order_item_view_model
        @order.add_item(product_id: '123', sku: 'SKU1')
        @order.add_item(product_id: '123', sku: 'SKU2')
        assert_equal('show', @view_model.items.first.options[:action])
      end

      def test_free_gifts_excludes_items_not_in_inventory
        create_inventory(id: 'SKU', available: 0)
        @order.items.build(sku: 'SKU', free_gift: true)
        assert(@view_model.free_gifts.empty?)
      end

      def test_shipping_options_is_empty_if_shipping_address_is_blank
        assert(@view_model.shipping_options.blank?)
      end
    end
  end
end
