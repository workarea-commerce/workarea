require 'test_helper'

module Workarea
  module Admin
    class BulkActionProductEditsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_empty_selection
        post admin.bulk_actions_path,
          params: {
            type: 'Workarea::BulkAction::ProductEdit',
            query_id: Search::AdminProducts.new.to_global_id,
            return_to: admin.catalog_products_path
          }

        assert_redirected_to(admin.catalog_products_path)
        assert_equal(flash[:error], I18n.t('workarea.admin.bulk_actions.empty_selection'))
      end

      def test_update
        product_one = create_product(active: false)
        product_two = create_product(active: false)

        post admin.bulk_actions_path,
          params: {
            type: 'Workarea::BulkAction::ProductEdit',
            query_id: Search::AdminProducts.new(q: 'foo', bar: %w(baz)).to_global_id,
            ids: [
              product_one.to_global_id.to_param,
              product_two.to_global_id.to_param
            ]
          }

        bulk_action = BulkAction::ProductEdit.first

        patch admin.bulk_action_product_edit_path(bulk_action),
          params: { bulk_action: { settings: { active: true } } }

        assert_redirected_to(admin.review_bulk_action_product_edit_path(bulk_action))
        assert_equal('true', bulk_action.reload.settings['active'])

        post admin.publish_bulk_action_product_edit_path(bulk_action),
          params: { activate: 'now' }

        assert(product_one.reload.active?)
        assert(product_two.reload.active?)
        assert(bulk_action.reload.completed?)
      end

      def test_publish
        product = create_product(active: false)
        bulk_action = create_bulk_action_product_edit(
          ids: [product.to_global_id.to_param],
          settings: { active: true }
        )

        post admin.publish_bulk_action_product_edit_path(bulk_action),
          params: { activate: 'new_release', release: {} }

        assert_equal(0, Release.count)
        assert(response.ok?) # did not redirect

        post admin.publish_bulk_action_product_edit_path(bulk_action),
          params: { activate: 'new_release', release: { name: 'Foo' } }

        assert_equal(1, Release.count)
        assert_redirected_to(admin.catalog_products_path)

        post admin.publish_bulk_action_product_edit_path(bulk_action),
          params: { activate: 'now' }

        assert_redirected_to(admin.catalog_products_path)
        assert(product.reload.active?)
      end
    end
  end
end
