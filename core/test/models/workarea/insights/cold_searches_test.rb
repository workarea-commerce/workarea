require 'test_helper'

module Workarea
  module Insights
    class ColdSearchesTest < TestCase
      def test_results
        create_search_by_week(
          query_string: 'foo',
          revenue_change: -1,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'bar',
          revenue_change: -4,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'baz',
          revenue_change: -2,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'qoo',
          revenue_change: -5,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'quz',
          revenue_change: -15,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'qux',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )

        ColdSearches.generate_weekly!
        assert_equal(1, ColdSearches.count)

        cold_searches = ColdSearches.first
        assert_equal(1, cold_searches.results.size)
        assert_equal('quz', cold_searches.results.first['query_id'])
        assert_equal('quz', cold_searches.results.first['query_string'])
        assert_equal(-15, cold_searches.results.first['revenue_change'])
      end

      def test_falling_back_to_fewer_deviations
        create_search_by_week(
          query_string: 'foo',
          revenue_change: -1,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'bar',
          revenue_change: -4,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'baz',
          revenue_change: -2,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'qoo',
          revenue_change: -5,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_string: 'qux',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )

        ColdSearches.generate_weekly!
        assert_equal(1, ColdSearches.count)

        cold_searches = ColdSearches.first
        assert_equal(1, cold_searches.results.size)
        assert_equal('qoo', cold_searches.results.first['query_id'])
        assert_equal('qoo', cold_searches.results.first['query_string'])
        assert_equal(-5, cold_searches.results.first['revenue_change'])
      end

      def test_revenue_change_median
        create_search_by_week(revenue_change: -1, reporting_on: 2.weeks.ago)
        [-1, -4, -2, -5, 0, 1].each do |change|
          create_search_by_week(
            revenue_change: change,
            reporting_on: Time.current.last_week
          )
        end

        assert_equal(-4, ColdSearches.revenue_change_median)
      end

      def test_revenue_change_standard_deviation
        create_search_by_week(revenue_change: -1, reporting_on: 2.weeks.ago)
        [-6, -2, -3, -1, 0, 1].each do |change|
          create_search_by_week(
            revenue_change: change,
            reporting_on: Time.current.last_week
          )
        end

        assert_in_delta(1.87, ColdSearches.revenue_change_standard_deviation)
      end

      def test_handles_weeks_without_declined_revenue
        create_search_by_week(
          query_id: 'foo',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )
        create_search_by_week(
          query_id: 'bar',
          revenue_change: 0,
          reporting_on: Time.current.last_week
        )

        ColdSearches.generate_weekly!
        assert_equal(0, ColdSearches.count)
      end
    end
  end
end
