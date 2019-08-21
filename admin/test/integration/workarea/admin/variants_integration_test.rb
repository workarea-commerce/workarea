require 'test_helper'

module Workarea
  module Admin
    class VariantsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :set_product

      def set_product
        @product = create_product(variants: [])
      end

      def test_can_create_a_variant
        post admin.catalog_product_variants_path(@product),
          params: {
            variant: { name: 'Test Asset', sku: 'SKU1234' },
            new_details: %w(Color Red)
          }

        @product.reload
        assert_equal(@product.variants.length, 1)
        assert_equal(@product.variants.first.sku, 'SKU1234')
        assert_equal(@product.variants.first.name, 'Test Asset')
        assert_equal(@product.variants.first.details['Color'], ['Red'])
      end

      def test_can_update_a_variant
        variant = @product.variants.create!(
          name: 'Test',
          sku: 'SKU1234',
          details: { 'Color' => 'Red' }
        )

        patch admin.catalog_product_variant_path(@product, variant),
          params: {
            variant: { name: 'New Name', sku: 'SKU5678' },
            details: %w(Color Blue),
            new_details: %w(Size Large)
          }

        @product.reload
        assert_equal(@product.variants.length, 1)
        assert_equal(@product.variants.first.sku, 'SKU5678')
        assert_equal(@product.variants.first.name, 'New Name')
        assert_equal(@product.variants.first.details['Color'], ['Blue'])
        assert_equal(@product.variants.first.details['Size'], ['Large'])
      end

      def test_can_destroy_an_asset
        variant = @product.variants.create!(sku: 'SKU1234')
        delete admin.catalog_product_variant_path(@product, variant)

        @product.reload
        assert(@product.variants.empty?)
      end

      def test_moving
        variant_one = @product.variants.create!(sku: '1')
        variant_two = @product.variants.create!(sku: '2')
        variant_three = @product.variants.create!(sku: '3')

        post admin.move_catalog_product_variants_path(@product),
          params: {
            positions: {
              variant_three.id => 0,
              variant_two.id => 1,
              variant_one.id => 2
            }
          }

        assert_equal(0, variant_three.reload.position)
        assert_equal(1, variant_two.reload.position)
        assert_equal(2, variant_one.reload.position)
      end
    end
  end
end
