require 'test_helper'

module Workarea
  module Admin
    class ProductCopySystemTest < Workarea::SystemTest
      include Admin::IntegrationTest

      def test_copy_from_product_show
        product = create_product

        visit admin.catalog_product_path(product)
        click_link t('workarea.admin.catalog_products.show.copy_product')

        fill_in 'product[id]', with: 'FOOBAR'

        click_button 'create_copy'
        assert(page.has_content?('Success'))
        assert_current_path(
          admin.edit_create_catalog_product_path(
            "#{product.slug}-1",
            continue: true
          )
        )
      end

      def test_copy_from_create_workflow
        create_product(name: 'Original Product')

        visit admin.create_catalog_products_path
        click_link t('workarea.admin.create_catalog_products.setup.copy_button')

        find('.select2-selection--single').click
        find('.select2-results__option', text: 'Original Product').click

        fill_in 'product[id]', with: 'FOOBAR'

        click_button 'create_copy'
        assert(page.has_content?('Success'))
        assert_current_path(
          admin.edit_create_catalog_product_path(
            'original-product-1',
            continue: true
          )
        )
      end
    end
  end
end
