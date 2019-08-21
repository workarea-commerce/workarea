require 'test_helper'

module Workarea
  module Insights
    class PopularSearchesTest < TestCase
      def test_results
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 27))

        2.times do
          Metrics::SearchByDay.save_search('foo', 2, at: Time.zone.local(2018, 10, 28))
        end

        3.times do
          Metrics::SearchByDay.save_search('foo', 3, at: Time.zone.local(2018, 10, 29))
        end

        2.times do
          Metrics::SearchByDay.save_search('bar', 1, at: Time.zone.local(2018, 10, 27))
        end

        3.times do
          Metrics::SearchByDay.save_search('bar', 2, at: Time.zone.local(2018, 10, 28))
        end

        4.times do
          Metrics::SearchByDay.save_search('bar', 3, at: Time.zone.local(2018, 10, 29))
        end

        travel_to Time.zone.local(2018, 11, 1)

        PopularSearches.generate_monthly!
        assert_equal(1, PopularSearches.count)

        popular_searches = PopularSearches.first
        assert_equal(2, popular_searches.results.size)
        assert_equal('bar', popular_searches.results.first['query_string'])
        assert_equal(9, popular_searches.results.first['searches'])
        assert_equal(3, popular_searches.results.first['total_results'])
        assert_equal('foo', popular_searches.results.second['query_string'])
        assert_equal(6, popular_searches.results.second['searches'])
        assert_equal(3, popular_searches.results.second['total_results'])
      end
    end
  end
end
