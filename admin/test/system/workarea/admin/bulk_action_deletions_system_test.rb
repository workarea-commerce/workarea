require 'test_helper'

module Workarea
  module Admin
    class BulkActionDeletionsSystemTest < Workarea::SystemTest
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
          create_product(id: "PROD#{id}", name: "Test Product #{id}")
        end
      end

      def test_deleting_in_bulk
        visit admin.catalog_products_path

        check 'catalog_product_PROD0'
        check 'catalog_product_PROD2'
        click_button t('workarea.admin.bulk_action_deletions.button')

        assert(page.has_content?('Success'))
        assert(page.has_no_content?(@products.first.name))
        assert(page.has_no_content?(@products.third.name))
        assert(page.has_content?(@products.second.name))
      end

      def test_deleting_in_bulk_beyond_confirmation_threshold
        visit admin.catalog_products_path

        @products.first(5).each do |product|
          check "catalog_product_#{product.id}"
        end

        click_button t('workarea.admin.bulk_action_deletions.button')

        bulk_action = BulkAction::Deletion.last
        assert_current_path(
          admin.edit_bulk_action_deletion_path(
            bulk_action,
            return_to: admin.catalog_products_path
          )
        )

        click_button 'confirm_bulk_delete'

        assert(page.has_content?('Success'))
        @products.first(5).each do |product|
          assert(page.has_no_content?(product.name))
        end

        assert(page.has_content?(@products[5].name))
        assert(page.has_content?(@products[6].name))
        assert(page.has_content?(@products[7].name))
        assert(page.has_content?(@products[8].name))
        assert(page.has_content?(@products[9].name))
      end
    end
  end
end
