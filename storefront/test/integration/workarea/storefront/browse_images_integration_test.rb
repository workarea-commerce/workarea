require 'test_helper'

module Workarea
  module Storefront
    class BrowseImagesIntegrationTest < Workarea::IntegrationTest
      setup :set_search_settings, :create_products_with_images

      def set_search_settings
        Workarea::Search::Settings.current.update_attributes!(
          terms_facets: %w(Color)
        )
      end

      def product_image_path(image)
        Workarea::Core::Engine.routes.url_helpers.dynamic_product_image_path(
          image.product,
          image.option,
          image.id,
          :large_thumb
        )
      end

      def create_products_with_images
        @product = create_product(
          name: "Test Product",
          filters: { 'color' => ['red', 'blue'] },
          images: [
            { image: product_image_file_path, option: 'blue', position: 1 },
            { image: product_image_file_path, option: 'red', position: 2 }
          ]
        )

        @product_two = create_product(
          name: "Another Test Product",
          filters: { 'color' => ['red', 'orange'] },
          images: [
            { image: product_image_file_path, option: 'red', position: 1 },
            { image: product_image_file_path, option: 'orange', position: 2 }
          ]
        )
      end

      def test_category_browse_product_images
        category = create_category(product_ids: [@product.id, @product_two.id])

        get storefront.category_path(category)

        assert_includes(response.body, product_image_path(@product.images.first))
        refute_includes(response.body, product_image_path(@product.images.last))
        assert_includes(response.body, product_image_path(@product_two.images.first))

        get storefront.category_path(category, color: 'red')
        assert_includes(response.body, product_image_path(@product.images.last))
        refute_includes(response.body, product_image_path(@product.images.first))
        assert_includes(response.body, product_image_path(@product_two.images.first))
      end

      def test_search_product_images
        get storefront.search_path(q: 'test')
        assert_includes(response.body, product_image_path(@product.images.first))
        refute_includes(response.body, product_image_path(@product.images.last))
        assert_includes(response.body, product_image_path(@product_two.images.first))

        get storefront.search_path(q: 'test', color: 'red')
        assert_includes(response.body, product_image_path(@product.images.last))
        refute_includes(response.body, product_image_path(@product.images.first))
        assert_includes(response.body, product_image_path(@product_two.images.first))
      end
    end
  end
end
