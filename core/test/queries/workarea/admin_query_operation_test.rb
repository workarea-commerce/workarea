require 'test_helper'

module Workarea
  class AdminQueryOperationTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_use_query
      op = AdminQueryOperation.new
      assert(op.use_query?)

      op = AdminQueryOperation.new(ids: %w(1 2 3))
      refute(op.use_query?)
    end

    def test_count
      products = Array.new(3) { |i| create_product(name: "Foo#{i}") }
      products.each { |p| Search::Admin.for(p).save }

      query = Search::AdminProducts.new
      op = AdminQueryOperation.new(query_id: query.to_global_id)
      assert_equal(3, op.count)

      query = Search::AdminProducts.new(q: 'foo1 foo2')
      op = AdminQueryOperation.new(query_id: query.to_global_id)
      assert_equal(2, op.count)

      query = Search::AdminProducts.new(q: 'foo1 foo2')
      op = AdminQueryOperation.new(
        query_id: query.to_global_id,
        exclude_ids: products.last.to_global_id
      )
      assert_equal(1, op.count)

      op = AdminQueryOperation.new(ids: products.map(&:to_global_id))
      assert_equal(3, op.count)

      op = AdminQueryOperation.new(
        ids: products.map(&:to_global_id),
        exclude_ids: products.first.to_global_id
      )
      assert_equal(2, op.count)

      op = AdminQueryOperation.new(ids: products.first.to_global_id)
      assert_equal(1, op.count)

      op = AdminQueryOperation.new(
        ids: products.first.to_global_id,
        exclude_ids: products.last.to_global_id
      )
      assert_equal(1, op.count)
    end

    def test_query_delegations
      services = Array.new(3) { create_shipping_service }

      query = AdminSearchQueryWrapper.new
      op = AdminQueryOperation.new(
        query_id: query.to_gid_param,
        model_type: 'Workarea::Shipping::Service'
      )

      assert_equal(3, op.count)
      assert_equal(3, op.results.count)
      assert_equal('Workarea::Shipping::Service', op.params[:model_type])
    end
  end
end
