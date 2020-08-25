require 'test_helper'

module Workarea
  module Storefront
    module ProductTemplates
      class OptionThumbnailsViewModelTest < Workarea::TestCase
        def test_groups_images_by_options
          product = create_product(
            images: [
              { image: product_image_file_path, option: 'blue' },
              { image: product_image_file_path, option: 'red' },
              { image: product_image_file_path, option: 'Blue' },
              { image: product_image_file_path, option: nil },
            ]
         )

         view_model = OptionThumbnailsViewModel.wrap(product)
         assert_equal(3, view_model.images_by_option.size)
         assert_equal(2, view_model.images_by_option['blue'].size)
         assert_equal(1, view_model.images_by_option['red'].size)
        end
      end
    end
  end
end
