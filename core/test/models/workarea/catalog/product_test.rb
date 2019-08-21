require 'test_helper'

module Workarea
  module Catalog
    class ProductTest < TestCase
      include NavigableTest

      def navigable_class
        Product
      end

      def test_find_for_update_by_sku
        product_one = create_product(variants: [{ sku: 'SKU1' }, { sku: 'SKU2' }])
        product_two = create_product(variants: [{ sku: 'SKU2' }])
        create_product(variants: [{ sku: 'SKU4' }])

        results = Product.find_for_update_by_sku('SKU2').to_a
        assert_includes(results, product_one)
        assert_includes(results, product_two)
      end

      def test_find_by_sku
        product = create_product(variants: [{ sku: 'SKU1' }])
        assert_equal(product, Product.find_by_sku('SKU1'))
        assert_equal(product, Product.find_by_sku('sku1'))
        assert_equal(product, Product.find_by_sku('Sku1'))
        assert_nil(Product.find_by_sku('SKU'))
        assert_nil(Product.find_by_sku(nil))
        assert_nil(Product.find_by_sku(''))
      end

      def test_find_ordered_for_display
        products = [create_product, create_product]

        results = Product.find_ordered_for_display(products.map(&:id).reverse)
        assert_equal(products.reverse, results)

        products.first.update_attributes(active: false)
        products.first.reload

        results = Product.find_ordered_for_display(products.map(&:id))
        assert_equal([products.last], results)
      end

      def test_valid?
        product = Product.new

        product.details = { 'foo' => {} }
        product.valid?
        assert_equal({}, product.details)

        product.details = { 'foo' => 'bar' }
        product.valid?
        assert_equal({ 'foo' => ['bar'] }, product.details)

        product.name = 'Foo'

        product.filters = { 'color' => 'blue' }
        assert(product.valid?)

        product.filters = { 'color' => 'blue', 'type' => 'bar' }
        product.valid?
        assert_includes(product.errors, :filters)
      end

      def test_active?
        product = create_product
        product.active = true
        product.variants.clear

        refute(product.active?)
      end

      def test_purchasable?
        product = create_product
        assert(product.purchasable?)

        product.variants.clear
        refute(product.purchasable?)
      end
    end
  end
end
