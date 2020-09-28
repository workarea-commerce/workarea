require 'test_helper'

module Workarea
  module Admin
    class InventorySkusSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        visit admin.inventory_skus_path
        click_link 'add_inventory_sku'

        fill_in 'sku[id]', with: 'SKU1'
        click_button 'create_sku'
        assert(page.has_content?('Success'))
        assert(page.has_content?('SKU1'))

        click_link 'Attributes'
        fill_in 'sku[available]', with: '10'
        click_button 'save_sku'
        assert(page.has_content?('Success'))
        assert(page.has_content?('10'))

        visit admin.inventory_skus_path
        assert(page.has_ordered_text?('SKU1', '10', '0', '0', 'Ignore'))

        visit admin.inventory_sku_path('SKU1')
        click_link 'Delete'

        assert_current_path(admin.inventory_skus_path)
        assert(page.has_content?('Success'))
        refute_text('SKU1')
      end

      def test_editing_a_non_existent_sku
        visit admin.edit_inventory_sku_path('SKU1')

        assert(page.has_content?('SKU1'))
        fill_in 'sku[available]', with: '10'
        click_button 'save_sku'
        assert(page.has_content?('Success'))
        assert(page.has_content?('SKU1'))
      end
    end
  end
end
