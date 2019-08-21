require 'test_helper'

module Workarea
  module Storefront
    class OrderViewModelTest < TestCase
      include TestCase::SearchIndexing

      setup :set_order

      def set_order
        @order = Order.new
      end

      def test_items_has_newest_first
        @order.add_item(product_id: '123', sku: 'SKU1')
        @order.add_item(product_id: '123', sku: 'SKU2')

        view_model = OrderViewModel.wrap(@order)
        assert_equal('SKU2', view_model.items.first.sku)
      end

      def test_status
        order = create_placed_order
        assert_equal('Placed', OrderViewModel.wrap(order).status)
        fulfill_order(order)
        assert_equal('Shipped', OrderViewModel.wrap(order).status)
      end

      def test_fulfillment_status
        order = create_placed_order
        assert_nil(OrderViewModel.wrap(order, fulfillment_status: 'not_available').fulfillment_status)
        assert_equal('Open', OrderViewModel.wrap(order, fulfillment_status: '').fulfillment_status)
        assert_equal('Open', OrderViewModel.wrap(order).fulfillment_status)

        Workarea::Fulfillment.find(order.id).destroy
        assert_nil(OrderViewModel.wrap(order).fulfillment_status)
      end

      def test_pending_items_returns_array_of_fulfillment_item_view_models
        @order.add_item(product_id: '123', sku: 'SKU1')
        @order.add_item(product_id: '123', sku: 'SKU2')

        CreateFulfillment.new(@order).perform
        view_model = OrderViewModel.wrap(@order)

        refute_empty(view_model.pending_items)

        view_model.pending_items.each do |item|
          assert_instance_of(Storefront::FulfillmentItemViewModel, item)
        end
      end

      def test_canceled_items_returns_array_of_fulfillment_item_view_models
        create_product(id: '123', variants: [{ sku: 'SKU1' }, { sku: 'SKU2' }])
        @order.add_item(product_id: '123', sku: 'SKU1')
        @order.add_item(product_id: '123', sku: 'SKU2')

        CreateFulfillment.new(@order).perform
        CancelOrder.new(@order).update_fulfillment

        view_model = OrderViewModel.wrap(@order)

        refute_empty(view_model.canceled_items)

        view_model.canceled_items.each do |item|
          assert_instance_of(Storefront::FulfillmentItemViewModel, item)
        end
      end

      def test_render_signup_form
        @order.email = 'anon7@workarea.com'
        view_model = OrderViewModel.wrap(@order)

        assert(view_model.render_signup_form?)

        create_user(email: @order.email)
        view_model = OrderViewModel.wrap(@order)

        assert_nil(view_model.user)
        refute(view_model.render_signup_form?)
      end
    end
  end
end
