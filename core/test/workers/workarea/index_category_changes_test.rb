require 'test_helper'

module Workarea
  class IndexCategoryChangesTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_indexing_category_changes
      product_one = create_product
      product_two = create_product
      product_three = create_product

      assert(Search::Storefront.count.zero?)

      IndexCategoryChanges.new.perform(
        'product_ids' => [
          [product_one.id], [product_two.id, product_three.id]
        ]
      )

      assert_equal(Search::Storefront.count, 3)
    end

    def test_index_large_category_changes
      Sidekiq::Testing.fake!

      products = Array.new(4) { create_product }

      Workarea.config.category_inline_index_product_max_count = 3

      IndexCategoryChanges.new.perform(
        'product_ids' => [[], products.map(&:id)]
      )

      assert_equal(4, IndexProduct.jobs.size)
    ensure
      Sidekiq::Testing.inline!
    end

    def test_require_index_ids
      worker = IndexCategoryChanges.new

      result = worker.require_index_ids(
        %w(3 1 4 2),
        %w(3 5 4 1)
      )
      assert_equal(%w(5 1 2), result)

      result = worker.require_index_ids(nil, %w(1 4 2))
      assert_equal(%w(1 4 2), result)

      result = worker.require_index_ids(%w(1 4 2), nil)
      assert_equal(%w(1 4 2), result)

      result = worker.require_index_ids(%w(1 4 2), %w(1 4 2))
      assert_equal([], result)

      result = worker.require_index_ids(%w(1 2 4), %w(1 4 2))
      assert_equal(%w(4 2), result)
    end
  end
end
