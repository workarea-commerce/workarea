require 'test_helper'

module Workarea
  class BulkActionSelectionsTest < TestCase
    include SearchIndexing

    def test_results
      products = Array.new(10) { |i| create_product(name: "Test Product #{i}") }
      products.each { |p| Search::Admin.for(p).save }

      action = create_bulk_action_product_edit()
      action.set(ids: []) # remove ids added on save to simulate query-based action
      query = BulkActionSelections.new(action.id)

      assert_equal(10, query.results.size)
      assert_equal(1, query.results.total_pages)

      action = create_bulk_action_product_edit(
        exclude_ids: products.first(6).map(&:to_global_id).map(&:to_param)
      )
      query = BulkActionSelections.new(action.id)

      assert_equal(4, query.results.size)
      assert_equal(1, query.results.total_pages)

      action = create_bulk_action_product_edit(
        ids: products.first(6).map(&:to_global_id).map(&:to_param),
      )
      query = BulkActionSelections.new(action.id)

      assert_equal(6, query.results.size)
      assert_equal(1, query.results.total_pages)
    end
  end
end
