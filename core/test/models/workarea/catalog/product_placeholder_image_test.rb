require 'test_helper'

module Workarea
  module Catalog
    class ProductPlaceholderImageTest < TestCase
      def test_placeholder?
        assert(ProductPlaceholderImage.new.placeholder?)
      end

      def test_delegates_methods_to_its_asset
        image = ProductPlaceholderImage.new
        image.image = File.new(product_image_file_path)
        assert_equal(image.image.name, image.name)
      end
    end
  end
end
