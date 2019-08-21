require 'test_helper'

module Workarea
  module Storefront
    class PackageViewModelTest < TestCase
      def test_items_returns_array_of_fulfillment_item_view_models
        Storefront::FulfillmentMailer.stubs(:shipped).returns(stub_everything)

        order = create_order

        order.add_item(product_id: '123', sku: 'SKU1', quantity: 2)
        order.add_item(product_id: '123', sku: 'SKU2', quantity: 3)

        fulfillment = Fulfillment.new.tap do |f|
          order.items.each do |item|
            f.items.build(order_item_id: item.id, quantity: item.quantity)

            f.ship_items('1', ['id' => item.id, 'quantity' => 2])
          end
        end

        view_model = PackageViewModel.new(fulfillment.packages.first, order: order)

        view_model.items.each do |item|
          assert_instance_of(FulfillmentItemViewModel, item)
        end

        assert_equal([2,2], view_model.items.map(&:quantity))
      end
    end
  end
end
