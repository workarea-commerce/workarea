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

      # ES7 compatibility — percolate_document_type version detection
      def test_percolate_document_type_returns_doc_for_elasticsearch_6
        client = stub('es6', info: { 'version' => { 'number' => '6.8.23' } })
        Workarea.stubs(:elasticsearch).returns(client)
        assert_equal('_doc', CategoryQuery.percolate_document_type)
      end

      def test_percolate_document_type_returns_nil_for_elasticsearch_7
        client = stub('es7', info: { 'version' => { 'number' => '7.17.0' } })
        Workarea.stubs(:elasticsearch).returns(client)
        assert_nil(CategoryQuery.percolate_document_type)
      end

      def test_percolate_document_type_returns_nil_when_version_unavailable
        client = stub('es_unavailable')
        client.stubs(:info).raises(StandardError, 'connection refused')
        Workarea.stubs(:elasticsearch).returns(client)
        assert_nil(CategoryQuery.percolate_document_type)
      end
    end
  end
end
