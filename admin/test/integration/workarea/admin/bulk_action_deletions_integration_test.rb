require 'test_helper'

module Workarea
  module Admin
    class BulkActionDeletionsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :set_confirmation_threshold, :create_products
      teardown :reset_confirmation_threshold

      def set_confirmation_threshold
        @threshold = Workarea.config.bulk_action_deletion_confirmation_threshold
        Workarea.config.bulk_action_deletion_confirmation_threshold = 5
      end

      def reset_confirmation_threshold
        Workarea.config.bulk_action_deletion_confirmation_threshold = @threshold
      end

      def create_products
        @products = Array.new(10) do |id|
          create_product(id: "PROD#{id}", name: 'foo', filters: { 'bar' => 'baz' })
        end
      end

      def test_create_below_threshold
        post admin.bulk_actions_path,
             params: {
               type: 'Workarea::BulkAction::Deletion',
               query_id: Workarea::Search::AdminProducts.new.to_gid_param,
               return_to: admin.catalog_products_path,
               bulk_action: {
                 ids: @products.first(3).map(&:to_gid_param),
                 exclude_ids: [],
                 model_type: 'Workarea::Catalog::Product'
               }
             }

        assert_equal(1, BulkAction::Deletion.count)

        result = BulkAction::Deletion.first
        assert_equal(@products.first(3).map(&:to_gid_param), result.ids)

        assert_redirected_to(
          admin.edit_bulk_action_deletion_path(
            result,
            return_to: admin.catalog_products_path
          )
        )
        follow_redirect!

        assert_equal(7, Catalog::Product.count)
        assert_redirected_to(admin.catalog_products_path)
      end

      def test_create_above_threshold_through_query
        search = Workarea::Search::AdminProducts.new(q: 'foo', bar: %w(baz))

        post admin.bulk_actions_path,
             params: {
               type: 'Workarea::BulkAction::Deletion',
               query_id: search.to_gid_param,
               return_to: admin.catalog_products_path,
               bulk_action: {
                 exclude_ids: @products.first(3).map(&:to_gid_param),
                 model_type: 'Workarea::Catalog::Product'
               }
             }

        assert_equal(1, BulkAction::Deletion.count)

        result = BulkAction::Deletion.first
        assert_equal(search.to_gid_param, result.query_id)
        assert_equal(@products.first(3).map(&:to_gid_param), result.exclude_ids)

        assert_redirected_to(
          admin.edit_bulk_action_deletion_path(
            result,
            return_to: admin.catalog_products_path
          )
        )

        follow_redirect!
        assert(response.ok?)
      end

      def test_create_above_threshold_through_manual_selection
        post admin.bulk_actions_path,
             params: {
               type: 'Workarea::BulkAction::Deletion',
               query_id: Workarea::Search::AdminProducts.new.to_gid_param,
               return_to: admin.catalog_products_path,
               bulk_action: {
                 ids: @products.first(6).map(&:to_gid_param),
                 model_type: 'Workarea::Catalog::Product'
               }
             }

        assert_equal(1, BulkAction::Deletion.count)

        result = BulkAction::Deletion.first
        assert_equal(@products.first(6).map(&:to_gid_param), result.ids)

        assert_redirected_to(
          admin.edit_bulk_action_deletion_path(
            result,
            return_to: admin.catalog_products_path
          )
        )

        follow_redirect!
        assert(response.ok?)
      end

      def test_create_above_threshold_for_items_without_summaries
        services = 10.times.map do |number|
          create_shipping_service(name: "Service #{number}")
        end
        ids = services.first(6).map(&:to_gid_param)
        params = {
          type: 'Workarea::BulkAction::Deletion',
          return_to: admin.shipping_services_path,
          bulk_action: {
            ids: ids,
            model_type: 'Workarea::Shipping::Service'
          }
        }
        query = AdminSearchQueryWrapper.new(params)

        post admin.bulk_actions_path, params: params.merge(query_id: query.to_gid_param)

        assert_equal(1, BulkAction::Deletion.count)

        result = BulkAction::Deletion.first
        assert_equal(ids, result.ids)

        assert_redirected_to(
          admin.edit_bulk_action_deletion_path(
            result,
            return_to: admin.shipping_services_path
          )
        )

        follow_redirect!
        assert_response(:success)
      end
    end
  end
end
