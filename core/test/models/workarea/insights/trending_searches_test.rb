require 'test_helper'

module Workarea
  module Insights
    class TrendingSearchesTest < TestCase
      def test_generate_monthly!
        create_search_by_week(
          query_string: 'foo',
          revenue_change: 10,
          orders: 5,
          reporting_on: Time.zone.local(2018, 12, 3)
        )
        create_search_by_week(
          query_string: 'foo',
          revenue_change: -10,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 10)
        )
        create_search_by_week(
          query_string: 'foo',
          revenue_change: 20,
          orders: 10,
          reporting_on: Time.zone.local(2018, 12, 17)
        )
        create_search_by_week(
          query_string: 'bar',
          revenue_change: 10,
          orders: 5,
          reporting_on: Time.zone.local(2018, 12, 3)
        )
        create_search_by_week(
          query_string: 'bar',
          revenue_change: -10,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 10)
        )
        create_search_by_week(
          query_string: 'bar',
          revenue_change: 0,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 17)
        )
        create_search_by_week(
          query_string: 'baz',
          revenue_change: 10,
          orders: 5,
          reporting_on: Time.zone.local(2018, 12, 3)
        )
        create_search_by_week(
          query_string: 'baz',
          revenue_change: -10,
          orders: 1,
          reporting_on: Time.zone.local(2018, 12, 10)
        )
        create_search_by_week(
          query_string: 'baz',
          revenue_change: 0,
          orders: 0,
          reporting_on: Time.zone.local(2018, 12, 17)
        )

        travel_to Time.zone.local(2019, 1, 17)
        TrendingSearches.generate_monthly!
        assert_equal(1, TrendingSearches.count)

        trending_searches = TrendingSearches.first
        assert_equal(3, trending_searches.results.size)

        assert_equal('foo', trending_searches.results.first['query_id'])
        assert_equal('foo', trending_searches.results.first['query_string'])
        assert_equal(2, trending_searches.results.first['improving_weeks'])
        assert_equal(15, trending_searches.results.first['orders'])

        assert_equal('baz', trending_searches.results.second['query_id'])
        assert_equal('baz', trending_searches.results.second['query_string'])
        assert_equal(1, trending_searches.results.second['improving_weeks'])
        assert_equal(6, trending_searches.results.second['orders'])

        assert_equal('bar', trending_searches.results.third['query_id'])
        assert_equal('bar', trending_searches.results.third['query_string'])
        assert_equal(1, trending_searches.results.third['improving_weeks'])
        assert_equal(5, trending_searches.results.third['orders'])
      end
    end
  end
end
