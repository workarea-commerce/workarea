require 'test_helper'

module Workarea
  module Insights
    class StarSearchesTest < TestCase
      def test_generate_weekly!
        create_search_by_week(
          query_string: 'foo',
          searches_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_search_by_week(
          query_string: 'bar',
          searches_percentile: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )
        create_search_by_week(
          query_string: 'baz',
          searches_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.01
        )
        create_search_by_week(
          query_string: 'qoo',
          searches_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.02
        )

        StarSearches.generate_weekly!
        assert_equal(1, StarSearches.count)

        star_searches = StarSearches.first
        assert_equal(1, star_searches.results.size)
        assert_equal('foo', star_searches.results.first['query_id'])
        assert_equal('foo', star_searches.results.first['query_string'])
        assert_equal(0.1, star_searches.results.first['conversion_rate'])
      end

      def test_avg_conversion_rate_of_top_two_searches_deciles
        create_search_by_week(
          searches_percentile: 100,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_search_by_week(
          searches_percentile: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )
        create_search_by_week(
          searches_percentile: 90,
          reporting_on: 2.weeks.ago,
          conversion_rate: 0.01
        )
        create_search_by_week(
          searches_percentile: 80,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.01
        )

        assert_in_delta(0.15, StarSearches.avg_conversion_rate_of_top_two_searches_deciles)
      end
    end
  end
end
