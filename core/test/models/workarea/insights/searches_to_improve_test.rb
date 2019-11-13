require 'test_helper'

module Workarea
  module Insights
    class SearchesToImproveTest < TestCase
      def test_results
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

        SearchesToImprove.generate_weekly!
        assert_equal(1, SearchesToImprove.count)

        searches_to_improve = SearchesToImprove.first
        assert_equal(2, searches_to_improve.results.size)
        assert_equal('baz', searches_to_improve.results.first['query_id'])
        assert_equal('baz', searches_to_improve.results.first['query_string'])
        assert_equal(0.01, searches_to_improve.results.first['conversion_rate'])
        assert_equal('qoo', searches_to_improve.results.second['query_id'])
        assert_equal('qoo', searches_to_improve.results.second['query_string'])
        assert_equal(0.02, searches_to_improve.results.second['conversion_rate'])
      end

      def test_falling_back_to_second_pass
        create_search_by_week(
          query_string: 'foo',
          searches_percentile: 90,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_search_by_week(
          query_string: 'bar',
          searches_percentile: 80,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.2
        )

        SearchesToImprove.generate_weekly!

        assert_empty(SearchesToImprove.first_pass)
        assert_equal(1, SearchesToImprove.count)

        searches_to_improve = SearchesToImprove.first
        assert_equal(1, searches_to_improve.results.size)
        assert_equal('foo', searches_to_improve.results.first['query_id'])
        assert_equal('foo', searches_to_improve.results.first['query_string'])
        assert_equal(0.1, searches_to_improve.results.first['conversion_rate'])
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

        assert_in_delta(0.15, SearchesToImprove.avg_conversion_rate_of_top_two_searches_deciles)
      end

      def test_avg_conversion_rate_of_top_five_searches_deciles
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
          conversion_rate: 0.1
        )
        create_search_by_week(
          searches_percentile: 80,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_search_by_week(
          searches_percentile: 70,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_search_by_week(
          searches_percentile: 60,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )
        create_search_by_week(
          searches_percentile: 50,
          reporting_on: Time.current.last_week,
          conversion_rate: 0.1
        )

        assert_in_delta(0.12, SearchesToImprove.avg_conversion_rate_of_top_five_searches_deciles)
      end
    end
  end
end
