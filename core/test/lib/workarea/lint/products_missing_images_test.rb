require 'test_helper'
require 'workarea/lint'

module Workarea
  class Lint
    load_lints

    class ProductsMissingImagesTest < TestCase
      def test_warns_for_each_product_missing_images
        3.times { create_product(images: []) }
        lint = ProductsMissingImages.new
        lint.run

        assert_equal(3, lint.warnings)
      end
    end
  end
end
