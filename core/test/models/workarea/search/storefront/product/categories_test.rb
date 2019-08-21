require 'test_helper'

module Workarea
  module Search
    class Storefront
      class Product
        class CategoriesTest < TestCase
          setup :set_models
          setup :setup_indexes

          def set_models
            @product = create_product(name: 'Foo')
            @category = create_category(
              product_rules: [
                { name: 'search', operator: 'equals', value: 'foo' }
              ]
            )
          end

          def setup_indexes
            Storefront.reset_indexes!
            IndexProduct.perform(@product)
          end

          def test_adds_a_category_to_percolator
            assert(Product.add_category(@category))
            assert_equal([@category.id.to_s], Product.find_categories(@product))
          end

          def test_does_not_add_a_category_without_rules
            category = create_category(product_rules: [])
            Product.add_category(category)
            assert_equal([], Product.find_categories(@product))
          end

          def test_products_that_dont_exist_in_the_index
            assert(Product.add_category(@category))
            product = create_product(name: 'Foo bar')

            result = Product.find_categories(product)
            assert_equal(1, result.length)
            assert_equal(@category.id.to_s, result.first)
          end

          def test_removes_the_category_from_the_percolator
            assert(Product.add_category(@category))
            Product.delete_category(@category.id)
            assert_equal([], Product.find_categories(@product))
          end

          def test_returns_over_ten_categories_in_percolator
            11.times do
              Product.add_category(
                create_category(
                  product_rules: [
                    {
                      name: 'search',
                      operator: 'equals',
                      value: '*'
                    }
                  ]
                )
              )
            end

            assert_equal(11, Product.find_categories(@product).size)
          end

          def test_includes_featured_category_ids_the_product_has
            Product.add_category(@category)

            category_1 = create_category(product_ids: [@product.id])
            category_2 = create_category(product_ids: [@product.id])
            category_3 = create_category(product_ids: [@product.id])

            results = Product.new(@product).category_id
            assert_equal(3, results.length)
            assert_includes(results, category_1.id)
            assert_includes(results, category_2.id)
            assert_includes(results, category_3.id)
          end

          def test_product_missing_from_storefront_index
            Storefront.delete_indexes!

            search_model = Product.new(@product)

            assert(search_model.destroy)
            assert_empty(Product.find_categories(@product))
          end
        end
      end
    end
  end
end
