require 'test_helper'

module Workarea
  class CartCleanerTest < Workarea::TestCase
    setup do
      @order = create_order
      @cleaner = CartCleaner.new(@order)
    end

    def test_removing_non_existent_products
      @order.add_item(product_id: 'foo', sku: 'bar')
      @cleaner.clean
      assert_empty(@order.items)
    end

    def test_removing_non_purchasable_products
      product = create_product(
        purchasable: false,
        variants: [
          { sku: 'SKU1', regular: 5.00 },
          { sku: 'SKU2', regular: 5.00 }
        ]
      )
      @order.add_item(product_id: product.id, sku: product.skus.first)
      @order.add_item(product_id: product.id, sku: product.skus.second)

      @cleaner.clean
      assert_empty(@order.items)
    end

    def test_removing_inactive_variant_items
      product = create_product(
        purchasable: true,
        variants: [
          { sku: 'SKU1', regular: 5.00, active: false },
          { sku: 'SKU2', regular: 5.00 }
        ]
      )
      @order.add_item(product_id: product.id, sku: product.skus.first)
      @order.add_item(product_id: product.id, sku: product.skus.second)

      @cleaner.clean
      assert_equal(1, @order.items.count)
    end

    def test_removing_items_missing_price
      product = Catalog::Product.create!(
        name: 'Integration Product',
        variants: [sku: 'SKU']
      )

      @order.add_item(product_id: product.id, sku: product.skus.first)
      @cleaner.clean
      assert_empty(@order.items)
    end

    def test_messaging
      product = create_product(purchasable: false)
      @order.add_item(product_id: product.id, sku: product.skus.first)

      @cleaner.clean
      assert_equal(@cleaner.messages.length, 1)
      assert(@cleaner.messages.first.include?(product.id))
    end
  end
end
