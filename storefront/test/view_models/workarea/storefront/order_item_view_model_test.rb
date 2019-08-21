require 'test_helper'

module Workarea
  module Storefront
    class OrderItemViewModelTest < TestCase
      def test_product
        product = create_product
        item = Order::Item.new(
          product_attributes: product.attributes,
          sku: product.skus.first
        )

        view_model = Storefront::OrderItemViewModel.new(item)
        assert_equal(product.skus.first, view_model.product.options[:sku])
      end

      def test_customizations_unit_price
        item = Order::Item.new

        assert_equal(
          0.to_m,
          Storefront::OrderItemViewModel.new(item).customizations_unit_price
        )

        item.price_adjustments.build(
          price: 'item',
          quantity: 1,
          amount: 10.to_m,
          description: 'test customizations'
        )

        assert_equal(
          10.to_m,
          Storefront::OrderItemViewModel.new(item).customizations_unit_price
        )
      end

      def test_default_category_name
        product = create_product
        create_category(name: 'Test 1', product_ids: [product.id.to_s])
        create_category(name: 'Test 2', product_ids: [product.id.to_s])
        item = Order::Item.new(sku: product.skus.first)

        view_model = Storefront::OrderItemViewModel.new(item)
        assert_equal('Test 1', view_model.default_category_name)
      end
    end
  end
end
