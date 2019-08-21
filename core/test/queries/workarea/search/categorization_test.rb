require 'test_helper'

module Workarea
  module Search
    class CategorizationTest < TestCase
      include TestCase::SearchIndexing

      def test_categorization_filtering
        create_product
        product_one = create_product
        product_two = create_product
        category_one = create_category(product_ids: [product_one.id])
        category_two = create_category(product_ids: [product_two.id])
        BulkIndexProducts.perform

        search = Categorization.new(category_ids: [category_one.id])
        assert_equal([product_one], search.results)

        search = Categorization.new(category_ids: [category_two.id])
        assert_equal([product_two], search.results)

        search = Categorization.new(
          category_ids: [category_one.id, category_two.id]
        )
        assert_equal(2, search.total)
        assert_includes(search.results, product_one)
        assert_includes(search.results, product_two)
      end
    end
  end
end
