require 'test_helper'

module Workarea
  module Storefront
    module ContentBlocks
      class ProductListViewModelTest < TestCase
        def test_returns_products_in_the_order_of_stored_product_ids
          block = Content::Block.new(
            type_id: :product_list,
            data: {
              products: [
                create_product(id: '1').id,
                create_product(id: '2').id
              ]
            }
          )

          view_model = ProductListViewModel.wrap(block)
          assert_equal(%w(1 2), view_model.products.map(&:id))
        end
      end
    end
  end
end
