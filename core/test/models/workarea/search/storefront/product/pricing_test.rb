require 'test_helper'

module Workarea
  module Search
    class Storefront
      class Product
        class PricingTest < TestCase
          setup :set_product

          def set_product
            @product = create_product(
              variants: [{ sku: '1' }, { sku: '2' }, { sku: '3' }]
            )

            create_inventory(id: '1', policy: 'standard', available: 0)
            create_inventory(id: '2', policy: 'ignore')
            create_inventory(id: '3', policy: 'ignore')

            Workarea::Pricing::Sku.find('1').prices = [{ regular: 1.to_m }]
            Workarea::Pricing::Sku.find('2').prices = [{ regular: 2.to_m }]
            Workarea::Pricing::Sku.find('3').prices = [{ regular: 3.to_m }]
          end

          def test_price
            search_model = Product.new(@product)
            assert_equal([2.0, 3.0], search_model.price)
          end

          def test_sort_price
            search_model = Product.new(@product)
            assert_equal(2.0, search_model.sort_price)

            Workarea::Pricing::Sku.destroy_all
            search_model = Product.new(@product)
            assert_equal(0.0, search_model.sort_price)
          end
        end
      end
    end
  end
end
