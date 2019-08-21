require 'test_helper'

module Workarea
  module Catalog
    class ProductPositionsTest < Workarea::TestCase
      setup do
        @product = create_product

        @categories = [
          create_category(name: 'Test Category 1', product_ids: ['123', @product.id]),
          create_category(name: 'Test Category 2', product_ids: ['123', '234', @product.id]),
          create_category(name: 'Test Category 3', product_ids: [])
        ]
      end

      def test_find
        result = ProductPositions.find(@product.id)
        assert_equal(
          result,
          @categories.first.id => 1,
          @categories.second.id => 2
        )
      end

      def test_find_for_categories
        result = ProductPositions.find(@product.id, categories: @categories.take(1))
        assert_equal(result, @categories.first.id => 1)
      end

      def test_find_for_category_ids
        category_ids = @categories.map(&:id).take(1)
        result = ProductPositions.find(@product.id, category_ids: category_ids)
        assert_equal(result, @categories.first.id => 1)
      end

      def test_omit_blank_values
        result = ProductPositions.find(@product.id, categories: [@categories.third])

        assert_empty(result)
      end
    end
  end
end
