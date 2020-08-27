require 'test_helper'

module Workarea
  module Catalog
    class ProductImageTest < TestCase
      def test_delegates_methods_to_its_asset
        product_image = Workarea::Catalog::ProductImage.new
        product_image.image = File.new(product_image_file_path)
        assert_equal(product_image.image.name, product_image.name)
      end

      def test_valid?
        product = create_product
        product.images.create(image: product_image_file_path, position: 0)

        image = product.images.build
        image.valid?

        assert_equal(1, image.position)
      end

      def test_always_order_by_position
        product = create_product
        product.images.create(image: product_image_file_path, position: 1)
        product.images.create(image: product_image_file_path, position: 0)
        product.reload

        assert_equal([0, 1], product.images.map(&:position))
      end

      def test_falling_back_to_recently_updated_sorting
        product = create_product
        one = product.images.create!(image: product_image_file_path, position: 0)
        two = product.images.create!(image: product_image_file_path, position: 0)
        assert_equal([two, one], product.reload.images)
      end

      def test_populate_fields
        product = create_product
        image = product.images.create!(image: product_image_file_path, position: 0)

        assert_equal(1.0, image.image_inverse_aspect_ratio)
      end
    end
  end
end
