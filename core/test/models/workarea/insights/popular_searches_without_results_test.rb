require 'test_helper'

module Workarea
  module Insights
    class PopularSearchesWithoutResultsTest < TestCase
      def test_results
        Metrics::SearchByDay.save_search('foo', 0, at: Time.zone.local(2018, 10, 27))
        Metrics::SearchByDay.save_search('foo', 0, at: Time.zone.local(2018, 10, 27))
        Metrics::SearchByDay.save_search('foo', 0, at: Time.zone.local(2018, 10, 27))
        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 27))
        Metrics::SearchByDay.save_search('bar', 0, at: Time.zone.local(2018, 10, 27))
        Metrics::SearchByDay.save_search('baz', 1, at: Time.zone.local(2018, 10, 27))

        travel_to Time.zone.local(2018, 11, 1)

        PopularSearchesWithoutResults.generate_monthly!
        assert_equal(1, PopularSearchesWithoutResults.count)

        popular_searches = PopularSearchesWithoutResults.first
        assert_equal(2, popular_searches.results.size)
        assert_equal('foo', popular_searches.results.first['query_string'])
        assert_equal(3, popular_searches.results.first['searches'])
        assert_equal('bar', popular_searches.results.second['query_string'])
        assert_equal(2, popular_searches.results.second['searches'])
      end
    end
  end
end
