require 'test_helper'

module Workarea
  module Admin
    class ProductImagesSystemTest < SystemTest
      include Admin::IntegrationTest

      setup :set_product

      def set_product
        @product = create_product
      end

      def test_managing_product_images
        visit admin.catalog_product_images_path(@product)

        #
        # Add Image
        #
        #
        attach_file 'image_image', product_image_file_path
        fill_in 'image_option', with: 'blue'
        click_button 'create_image'

        assert_equal(admin.catalog_product_images_path(@product), current_path)
        assert(page.has_content?('Success'))
        assert(page.has_content?('Blue Images'))

        #
        # Edit Image
        #
        #
        all('[data-product-images-sortable] .product-images__image')[0].hover
        click_link t('workarea.admin.catalog_product_images.index.edit_image')
        assert(page.has_content?('Blue Image'))
        assert(page.has_content?('Edit Image'))

        attach_file 'image_image', product_image_file_path
        fill_in 'image_option', with: 'black'
        click_button 'save_product_image'

        assert(page.has_content?('Success'))
        assert(page.has_content?('Black Images'))
        refute_match(/blue_0/m, page.html)

        #
        # Delete Image
        #
        #
        all('[data-product-images-sortable] .product-images__image')[0].hover
        click_link t('workarea.admin.catalog_product_images.index.delete_image')
        assert(page.has_content?('Success'))
        assert(page.has_no_content?('Black Images'))
      end

      def test_reordering_within_an_option
        visit admin.catalog_product_images_path(@product)

        attach_file 'image_image', product_image_file_path
        fill_in 'image_option', with: 'blue'
        click_button 'create_image'

        attach_file 'image_image', product_image_file_path
        fill_in 'image_option', with: 'blue'
        click_button 'create_image'

        assert(page.has_selector?('.ui-sortable'))
      end
    end
  end
end
