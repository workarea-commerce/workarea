require 'test_helper'

module Workarea
  class BulkIndexSearchesTest < TestCase
    include TestCase::SearchIndexing

    setup :set_config
    teardown :unset_config

    def set_config
      @current_max = Workarea.config.max_searches_to_index
      Workarea.config.max_searches_to_index = 3
    end

    def unset_config
      Workarea.config.max_searches_to_index = @current_max
    end

    def test_perform
      Search::Storefront.reset_indexes!

      2.times do
        Metrics::SearchByDay.save_search('foo', 1)
        2.times { Metrics::SearchByDay.save_search('bar', 2) }
        3.times { Metrics::SearchByDay.save_search('baz', 3) }
        4.times { Metrics::SearchByDay.save_search('qux', 4) }
        5.times { Metrics::SearchByDay.save_search('qoo', 0) }

        travel_to 1.week.from_now
        GenerateInsights.generate_all!
        BulkIndexSearches.perform
      end

      assert_equal(3, Search::Storefront.count)

      results = Search::Storefront.search('*')['hits']['hits']
      names = results.map { |r| r['_source']['content']['name'] }

      assert_includes(names, 'qux')
      assert_includes(names, 'baz')
      assert_includes(names, 'bar')
      refute_includes(names, 'qoo')
    end
  end
end
