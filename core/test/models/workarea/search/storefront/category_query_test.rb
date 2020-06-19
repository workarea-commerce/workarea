require 'test_helper'

module Workarea
  module Search
    class Storefront
      class CategoryQueryTest < TestCase
        include TestCase::SearchIndexing

        setup :set_models

        def set_models
          @product = create_product(name: 'Foo')
          @category = create_category(
            product_rules: [
              { name: 'search', operator: 'equals', value: 'foo' }
            ]
          )

          IndexProduct.perform(@product)
        end

        def test_adds_a_category_to_percolator
          assert(CategoryQuery.new(@category).create)
          assert_equal([@category.id.to_s], CategoryQuery.find_by_product(@product))
        end

        def test_does_not_add_a_category_without_rules
          category = create_category(product_rules: [])
          CategoryQuery.new(category).create
          assert_equal([], CategoryQuery.find_by_product(@product))
        end

        def test_products_that_dont_exist_in_the_index
          assert(CategoryQuery.new(@category).create)
          product = create_product(name: 'Foo bar')

          result = CategoryQuery.find_by_product(product)
          assert_equal(1, result.length)
          assert_equal(@category.id.to_s, result.first)
        end

        def test_removes_the_category_from_the_percolator
          assert(CategoryQuery.new(@category).create)
          CategoryQuery.new(@category).delete
          assert_equal([], CategoryQuery.find_by_product(@product))
        end

        def test_returns_over_ten_categories_in_percolator
          11.times do
            category = create_category(
              product_rules: [
                { name: 'search', operator: 'equals', value: '*' }
              ]
            )

            CategoryQuery.new(category).create
          end

          assert_equal(11, CategoryQuery.find_by_product(@product).size)
        end

        def test_product_missing_from_storefront_index
          Storefront.delete_indexes!
          assert_empty(CategoryQuery.find_by_product(@product))
        end

        def test_finding_a_product_with_current_release
          create_release.as_current do
            @product.update!(name: 'Bar')
            IndexProduct.perform(@product)
            assert_equal([], CategoryQuery.find_by_product(@product))

            @category.product_rules.first.update!(value: 'bar')
            CategoryQuery.new(@category).update
            assert_equal([@category.id.to_s], CategoryQuery.find_by_product(@product))
          end
        end

        def test_deleted_releases
          release = create_release
          release.as_current do
            @category.product_rules.first.update!(value: 'bar')
          end

          release.destroy
          CategoryQuery.new(@category).update
          assert_equal([@category.id.to_s], CategoryQuery.find_by_product(@product))
        end
      end
    end
  end
end
