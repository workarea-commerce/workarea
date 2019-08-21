require 'test_helper'

module Workarea
  module Admin
    class ProductImagesViewModelTest < TestCase
      def test_groups_ordered_images_by_their_option_value
        product = create_product
        green_2 = product.images.build(option: 'green', position: 2)
        green_1 = product.images.build(option: 'green', position: 1)

        red_2 = product.images.build(option: 'red', position: 2)
        red_1 = product.images.build(option: 'red', position: 1)

        view_model = ProductImagesViewModel.new(product)
        assert_equal(
          { 'Red' => [red_1, red_2], 'Green' => [green_1, green_2] },
          view_model.by_option
        )
      end
    end
  end
end
