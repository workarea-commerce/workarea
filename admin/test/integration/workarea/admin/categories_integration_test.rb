require 'test_helper'

module Workarea
  module Admin
    class CategoriesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_updates_a_category
        category = create_category

        patch admin.catalog_category_path(category),
          params: {
            category: {
              name: 'Test Category',
              slug: 'test-slug',
              client_id: 'client_id',
              default_sort: 'newest',
              show_navigation: false
            }
          }

        category.reload
        assert_equal('Test Category', category.name)
        assert_equal('test-slug', category.slug)
        assert_equal('client_id', category.client_id)
        assert_equal('newest', category.default_sort)
        refute(category.show_navigation?)
      end

      def test_deletes_a_category
        category = create_category
        delete admin.catalog_category_path(category)
        assert(Catalog::Category.empty?)
      end

      def test_autocompletes_partial_queries_when_xhr
        category = create_category(name: 'Test')
        get admin.catalog_categories_path(format: 'json', q: 'tes'), xhr: true

        results = JSON.parse(response.body)
        assert_equal(1, results['results'].length)
        assert(results['results'].first['label'].present?)
        assert_equal(category.id.to_s, results['results'].first['value'])
        refute(results['results'].first['top'])
      end

      def test_exclude_categories_from_search_results
        category = create_category(name: 'Category')
        ignored = create_category(name: 'Category')

        get admin.catalog_categories_path(exclude_ids: ignored.id, q: category.name, format: :json)

        results = JSON.parse(response.body).with_indifferent_access[:results]
        values = results.map { |result| result[:value] }

        assert_response(:success)
        refute_empty(values)
        assert_includes(values, category.id.to_s)
        refute_includes(values, ignored.id.to_s)
      end

      def test_returns_breadcrumb_as_title_with_json_response
        category = create_category(name: 'Test')
        create_taxon(
          name: 'Test',
          parent: create_taxon(name: 'Foo Bar'),
          navigable: category
        )

        get admin.catalog_categories_path(format: 'json', q: 'test'), xhr: true

        result = JSON.parse(response.body)['results'].first
        assert_equal(category.id.to_s, result['value'])
        assert_equal('Home > Foo Bar > Test', result['title'])
      end
    end
  end
end
