require 'test_helper'

module Workarea
  module Storefront
    module ContentBlocks
      class CategorySummaryViewModelTest < Workarea::TestCase
        include TestCase::SearchIndexing

        def test_products
          products = Array.new(3) { |i| create_product(name: "Test Product #{i}") }
          category = create_category(
            product_ids: [
              products.third.id,
              products.first.id,
              products.second.id
            ]
          )

          BulkIndexProducts.perform_by_models(products)

          block = Content::Block.new(
            type_id: 'category_summary',
            data: { 'category' => category.id }
          )

          view_model = ContentBlocks::CategorySummaryViewModel.new(block)
          assert_equal(
            ['Test Product 2', 'Test Product 0', 'Test Product 1'],
            view_model.products.map(&:name)
          )
        end
      end
    end
  end
end
