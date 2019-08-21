require 'test_helper'

module Workarea
  class PackagingTest < TestCase
    def order
      @order ||= Order.new(
        items: [
          { product_id: 'PROD1', sku: 'SKU1', quantity: 1, total_value: 3.to_m },
          { product_id: 'PROD2', sku: 'SKU2', quantity: 2, total_value: 5.to_m }
        ]
      )
    end

    def test_packages
      create_shipping_sku(id: 'SKU1', weight: 1)
      create_shipping_sku(id: 'SKU2', weight: 2)

      packaging = Packaging.new(order)
      assert_equal(5, packaging.total_weight)
    end

    def test_total_weight
      create_shipping_sku(id: 'SKU1', weight: 1, dimensions: [2, 3, 4])
      create_shipping_sku(id: 'SKU2', weight: 2, dimensions: [5, 6, 8])

      package = Packaging.new(order).packages.first

      assert_equal(5, package.weight.value)
      assert_equal(800, package.value)
    end

    def test_total_dimensions
      Workarea.config.shipping_dimensions = [1, 2, 3]

      packaging = Packaging.new(order)
      assert_equal([1, 2, 3], packaging.total_dimensions)

      create_shipping_sku(id: 'SKU1', dimensions: [2, 3, 4])
      create_shipping_sku(id: 'SKU2', dimensions: [5, 6, 8])

      packaging = Packaging.new(order)
      assert_equal(8, packaging.total_dimensions.first)
      assert_equal(6, packaging.total_dimensions.second)
      assert_equal(12, packaging.total_dimensions.third)
    end

    def test_total_value
      create_pricing_sku(id: 'SKU1', prices: [{ regular: 3.to_m }])
      create_pricing_sku(id: 'SKU2', prices: [{ regular: 2.5.to_m }])
      Pricing.perform(order)

      packaging = Packaging.new(order)
      assert_equal(8.to_m, packaging.total_value)

      create_order_total_discount(amount_type: :flat, amount: 1)
      Pricing.perform(order)

      packaging = Packaging.new(order)
      assert_equal(7.to_m, packaging.total_value)
    end

    def test_individual_dimensions
      create_shipping_sku(id: 'SKU1', dimensions: [2, 3, 4])
      packaging = Packaging.new(order)
      refute(packaging.individual_dimensions?)
    end

    def test_partial_shipping
      shipping = create_shipping(
        order_id: order.id,
        quantities: { order.items.first.id => 1, order.items.second.id => 1 }
      )

      create_shipping_sku(id: 'SKU1', weight: 1, dimensions: [2, 3, 4])
      create_shipping_sku(id: 'SKU2', weight: 2, dimensions: [5, 6, 8])

      packaging = Packaging.new(order, shipping)
      assert_equal(5.5.to_m, packaging.total_value)
      assert_equal(8, packaging.total_dimensions.first)
      assert_equal(6, packaging.total_dimensions.second)
      assert_equal(7, packaging.total_dimensions.third)
      assert_equal(3, packaging.total_weight)

      package = packaging.packages.first
      assert_equal(3, package.weight.value)
      assert_equal(550, package.value)
    end
  end
end
