require 'test_helper'

module Workarea
  module Admin
    class FulfillmentSkusSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        visit admin.fulfillment_skus_path
        click_link 'add_fulfillment_sku'

        fill_in 'sku[id]', with: 'SKU1'
        click_button 'create_sku'

        assert_current_path(admin.fulfillment_sku_path('SKU1'))
        assert(page.has_content?('Success'))
        assert(page.has_content?('SKU1'))

        click_link 'Attributes'
        select 'Download', from: 'sku[policy]'
        attach_file 'sku[file]', product_image_file_path
        click_button 'save_sku'

        assert(page.has_content?('Success'))
        assert_current_path(admin.fulfillment_sku_path('SKU1'))
        assert(page.has_content?('Download'))

        visit admin.fulfillment_sku_path('SKU1')
        click_link 'Delete'

        assert_current_path(admin.fulfillment_skus_path)
        assert(page.has_content?('Success'))
        assert(page.has_no_content?('SKU1'))
      end

      def test_accessing_from_variant
        product = create_product(variants: [{ sku: 'SKU1', regular: 5.to_m }])
        sku = create_fulfillment_sku(id: 'SKU1', policy: 'ignore')

        visit admin.catalog_product_variants_path(product)
        assert(page.has_content?('Ignore'))

        click_link 'Ignore'
        assert_current_path(admin.fulfillment_sku_path('SKU1'))
      end
    end
  end
end
