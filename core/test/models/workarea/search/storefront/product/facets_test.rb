require 'test_helper'

module Workarea
  module Search
    class Storefront
      class Product
        class FacetsTest < IntegrationTest
          def test_includes_all_text_from_the_product_facets
            product = Catalog::Product.new(
              filters: {
                'Size' => 'Large',
                'Color' => ['Red', 'Blue'],
                'Details' => {
                    'Material' => ['Cotton', 'Polyester']
                }
              }
            )

            text = Product.new(product).facets_content

            assert_includes(text, 'Size')
            assert_includes(text, 'Large')
            assert_includes(text, 'Color')
            assert_includes(text, 'Red')
            assert_includes(text, 'Blue')
            assert_includes(text, 'Details')
            assert_includes(text, 'Material')
            assert_includes(text, 'Cotton')
            assert_includes(text, 'Polyester')
          end
        end
      end
    end
  end
end
