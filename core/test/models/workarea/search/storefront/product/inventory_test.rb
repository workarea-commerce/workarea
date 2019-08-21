require 'test_helper'

module Workarea
  module Search
    class Storefront
      class Product
        class InventoryTest < TestCase
          def test_skus_with_displayable_inventory
            create_inventory(id: '1', policy: 'standard', available: 0)
            create_inventory(id: '2', policy: 'ignore')
            product = create_product(
              variants: [{ sku: '1' }, { sku: '2' }]
            )

            results = Product.new(product).skus_with_displayable_inventory
            assert_equal(1, results.length)
            assert_equal('2', results.first)
          end
        end
      end
    end
  end
end
