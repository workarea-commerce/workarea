require 'test_helper'

module Workarea
  module Metrics
    class SearchByWeekTest < TestCase
      def test_last_week
        two_weeks_ago = create_search_by_week(reporting_on: Time.zone.local(2018, 11, 25))
        last_week = create_search_by_week(reporting_on: Time.zone.local(2018, 12, 2))
        this_week = create_search_by_week(reporting_on: Time.zone.local(2018, 12, 5))

        travel_to Time.zone.local(2018, 12, 5)
        refute(SearchByWeek.last_week.include?(two_weeks_ago))
        assert(SearchByWeek.last_week.include?(last_week))
        refute(SearchByWeek.last_week.include?(this_week))
      end

      def test_by_searches_percentile
        first = create_search_by_week(searches_percentile: 100)
        second = create_search_by_week(searches_percentile: 90)
        third = create_search_by_week(searches_percentile: 80)
        fourth = create_search_by_week(searches_percentile: 70)

        assert_equal([first], SearchByWeek.by_searches_percentile(100))
        assert_equal([second], SearchByWeek.by_searches_percentile(90))
        assert_equal([second, first], SearchByWeek.by_searches_percentile(81..100))
        assert_equal([third, second], SearchByWeek.by_searches_percentile(71..90))
        assert_equal([fourth, third, second], SearchByWeek.by_searches_percentile(61..90))
      end

      def test_improved_revenue
        create_search_by_week(revenue_change: -1)
        create_search_by_week(revenue_change: 0)
        create_search_by_week(revenue_change: 1)
        create_search_by_week(revenue_change: nil)

        assert_equal(1, SearchByWeek.improved_revenue.count)
        assert_equal(1, SearchByWeek.improved_revenue.first.revenue_change)
      end

      def test_declined_revenue
        create_search_by_week(revenue_change: -1)
        create_search_by_week(revenue_change: 0)
        create_search_by_week(revenue_change: 1)
        create_search_by_week(revenue_change: nil)

        assert_equal(1, SearchByWeek.declined_revenue.count)
        assert_equal(-1, SearchByWeek.declined_revenue.first.revenue_change)
      end

      def test_append_last_week!
        Workarea.config.insights_aggregation_per_page = 1

        SearchForLastWeek.create!(query_id: 'foo', orders: 1)
        SearchByWeek.append_last_week!
        assert_equal(1, SearchByWeek.count)

        search = SearchByWeek.find_by(query_id: 'foo')
        assert_equal('foo', search.query_id)
        assert_equal(1, search.orders)

        SearchForLastWeek.delete_all
        SearchForLastWeek.create!(query_id: 'foo', orders: 1)
        SearchForLastWeek.create!(query_id: 'bar', orders: 2)
        SearchByWeek.append_last_week!
        assert_equal(3, SearchByWeek.count)

        foo = SearchByWeek.find_by(query_id: 'foo')
        assert_equal('foo', foo.query_id)
        assert_equal(1, foo.orders)

        bar = SearchByWeek.find_by(query_id: 'bar')
        assert_equal('bar', bar.query_id)
        assert_equal(2, bar.orders)
      end

      def test_revenue_change_median
        create_search_by_week(revenue_change: 1)
        create_search_by_week(revenue_change: 2)
        create_search_by_week(revenue_change: 3)
        assert_equal(2, SearchByWeek.revenue_change_median)

        create_search_by_week(revenue_change: 4)
        assert_equal(3, SearchByWeek.revenue_change_median)

        create_search_by_week(revenue_change: 5)
        assert_equal(3, SearchByWeek.revenue_change_median)

        create_search_by_week(revenue_change: 6)
        assert_equal(4, SearchByWeek.revenue_change_median)
      end

      def test_score
        two_weeks_ago = create_search_by_week(
          orders: 1,
          reporting_on: Time.zone.local(2018, 11, 25)
        )

        last_week = create_search_by_week(
          orders: 2,
          reporting_on: Time.zone.local(2018, 12, 2)
        )

        this_week = create_search_by_week(
          orders: 3,
          reporting_on: Time.zone.local(2018, 12, 5)
        )

        travel_to Time.zone.local(2018, 12, 5)

        Workarea.config.score_decay = 0.5

        assert_equal(3, this_week.score(:orders))
        assert_equal(1, last_week.score(:orders))
        assert_equal(0.25, two_weeks_ago.score(:orders))
      end

      def test_weeks_ago
        model = create_search_by_week(reporting_on: Time.zone.local(2019, 1, 25))

        travel_to Time.zone.local(2019, 1, 25)
        assert_equal(0, model.weeks_ago)

        travel_to Time.zone.local(2019, 1, 27)
        assert_equal(0, model.weeks_ago)

        travel_to Time.zone.local(2019, 2, 8)
        assert_equal(2, model.weeks_ago)

        travel_to Time.zone.local(2019, 2, 9)
        assert_equal(2, model.weeks_ago)

        travel_to Time.zone.local(2019, 2, 11)
        assert_equal(3, model.weeks_ago)
      end
    end
  end
end
