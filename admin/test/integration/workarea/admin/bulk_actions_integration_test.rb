require 'test_helper'

module Workarea
  module Admin
    class BulkActionsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        6.times.each do |id|
          create_product(id: id, name: 'foo', filters: { 'bar' => 'baz' })
        end
        post admin.bulk_actions_path,
          headers: { 'Referer' => admin.catalog_products_path },
          params: {
            type: 'Workarea::BulkAction::ProductEdit',
            query_id: Search::AdminProducts.new(q: 'foo', bar: %w(baz)).to_global_id,
            ids: %w(1 2 3),
            exclude_ids: %w(4 5 6)
          }

        assert_equal(1, BulkAction.count)
        assert_equal(1, BulkAction::ProductEdit.count)

        result = BulkAction::ProductEdit.first
        assert_equal(%w(1 2 3), result.ids)
        assert_equal(%w(4 5 6), result.exclude_ids)

        assert_redirected_to(admin.edit_bulk_action_product_edit_path(result))
      end

      def test_destroy
        query = Search::AdminProducts.new
        action = BulkAction.create!(query_id: query.to_global_id)

        delete admin.bulk_action_path(action)

        assert_equal(0, BulkAction.count)
        assert_raises(Mongoid::Errors::DocumentNotFound) { action.reload }
      end
    end
  end
end
