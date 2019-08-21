require 'test_helper'

module Workarea
  module Search
    class SearchSuggestionsTest < IntegrationTest
      def test_results
        Metrics::SearchByDay.save_search('test', 1)
        2.times { Metrics::SearchByDay.save_search('test product', 2) }
        travel_to 1.week.from_now
        GenerateInsights.generate_all!
        BulkIndexSearches.perform

        create_product(name: 'test product 1')
        create_product(name: 'test product 2', active: false)
        BulkIndexProducts.perform

        results = SearchSuggestions.new(q: 'tes').results

        assert_equal(3, results.length)
        assert_results_include(results, 'test product')
        assert_results_include(results, 'test')
        assert_results_include(results, 'test product 1')
      end

      def test_results_in_release
        Metrics::SearchByDay.save_search('test', 1)
        2.times { Metrics::SearchByDay.save_search('test product', 2) }
        travel_to 1.week.from_now
        GenerateInsights.generate_all!
        BulkIndexSearches.perform

        product_one = create_product(name: 'test product 1')
        product_two = create_product(name: 'test product 2')
        BulkIndexProducts.perform

        results = SearchSuggestions.new(q: 'tes').results
        assert_equal(4, results.length)
        assert_results_include(results, 'test product')
        assert_results_include(results, 'test')
        assert_results_include(results, 'test product 1')
        assert_results_include(results, 'test product 2')

        create_release.as_current do
          product_two.update!(active: false)

          results = SearchSuggestions.new(q: 'tes').results
          assert_equal(3, results.length)
          assert_results_include(results, 'test product')
          assert_results_include(results, 'test')
          assert_results_include(results, 'test product 1')
        end

        results = SearchSuggestions.new(q: 'tes').results
        assert_equal(4, results.length)
        assert_results_include(results, 'test product')
        assert_results_include(results, 'test')
        assert_results_include(results, 'test product 1')
        assert_results_include(results, 'test product 2')

        create_release.as_current do
          product_two.update!(name: 'test 4', active: true)

          results = SearchSuggestions.new(q: 'tes').results
          assert_equal(4, results.length)
          assert_results_include(results, 'test product')
          assert_results_include(results, 'test')
          assert_results_include(results, 'test product 1')
          assert_results_include(results, 'test 4')
        end
      end

      def assert_results_include(results, name)
        refute_nil(results.detect { |r| r['_source']['content']['name'] == name })
      end
    end
  end
end
