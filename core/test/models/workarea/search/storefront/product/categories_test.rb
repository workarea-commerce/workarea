require 'test_helper'

module Workarea
  module Search
    class Storefront
      class Product
        class CategoriesTest < TestCase
          include TestCase::SearchIndexing

          def test_includes_featured_category_ids_the_product_has
            product = create_product(name: 'Foo')
            category = create_category(
              product_rules: [
                { name: 'search', operator: 'equals', value: 'foo' }
              ]
            )

            IndexProduct.perform(product)
            CategoryQuery.new(category).create

            category_1 = create_category(product_ids: [product.id])
            category_2 = create_category(product_ids: [product.id])
            category_3 = create_category(product_ids: [product.id])

            results = Product.new(product).category_id
            assert_equal(3, results.length)
            assert_includes(results, category_1.id)
            assert_includes(results, category_2.id)
            assert_includes(results, category_3.id)
          end
        end
      end
    end
  end
end
