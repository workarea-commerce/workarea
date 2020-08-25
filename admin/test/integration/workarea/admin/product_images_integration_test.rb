require 'test_helper'

module Workarea
  module Admin
    class ProductImagesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest
      setup :set_product

      def set_product
        @product = create_product
      end

      def test_creates_an_image
        post admin.catalog_product_images_path(@product),
          params: { image: { image: product_image_file_path, option: 'blue' } }

        @product.reload
        assert_equal(1, @product.images.length)
        assert_equal('blue', @product.images.first.option)
      end

      def test_updates_image_ordering
        image1 = @product.images.create!(
          image: product_image_file_path,
          option: 'blue'
        )

        image2 = @product.images.create!(
          image: product_image_file_path,
          option: 'blue'
        )

        post admin.positions_catalog_product_images_path(@product),
          params: { order: [image2.id, image1.id] }

        image1.reload
        assert_equal(1, image1.position)

        image2.reload
        assert_equal(0, image2.position)
      end

      def test_returns_a_list_of_matching_image_option_values
        @product.images.create!(
          image: product_image_file_path,
          option: 'blue'
        )

        get admin.options_catalog_product_images_path(@product, format: 'json', q: 'bl')

        results = JSON.parse(response.body)
        assert_equal([{ 'label' => 'Blue', 'value' => 'Blue' }], results['results'])
      end

      def test_destroys_an_image
        image = @product.images.create!(
          image: product_image_file_path,
          option: 'blue'
        )

        delete admin.catalog_product_image_url(@product, image)

        @product.reload
        assert_empty(@product.images)
      end
    end
  end
end
