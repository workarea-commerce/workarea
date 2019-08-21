require 'test_helper'

module Workarea
  module Search
    class SearchSuggestionsTest < TestCase
      include SearchIndexing

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

        refute_nil(results.detect { |r| r['_source']['content']['name'] == 'test product' })
        refute_nil(results.detect { |r| r['_source']['content']['name'] == 'test' })
        refute_nil(results.detect { |r| r['_source']['content']['name'] == 'test product 1' })
      end
    end
  end
end
