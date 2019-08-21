require 'test_helper'

module Workarea
  module Reports
    class FirstTimeVsReturningSalesTest < TestCase
      def test_by_day
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 27), orders: 1, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 28), orders: 2, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 3, returning_orders: 1)

        travel_to Time.zone.local(2018, 10, 30)
        report = FirstTimeVsReturningSales.new(group_by: 'day', sort_by: '_id', sort_direction: 'desc')

        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(2, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(33.333, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(1, report.results.second['first_time_orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_in_delta(50.000, report.results.second['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(10, report.results.third['_id']['month'])
        assert_equal(27, report.results.third['_id']['day'])
        assert_equal(1, report.results.third['orders'])
        assert_equal(0, report.results.third['first_time_orders'])
        assert_equal(1, report.results.third['returning_orders'])
        assert_in_delta(100.000, report.results.third['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.third['starts_at'])

        report = FirstTimeVsReturningSales.new(group_by: 'day', sort_by: '_id', sort_direction: 'asc')
        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(27, report.results.first['_id']['day'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(10, report.results.third['_id']['month'])
        assert_equal(29, report.results.third['_id']['day'])
      end

      def test_by_day_of_week
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 27), orders: 1, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 28), orders: 2, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 3, returning_orders: 1)

        travel_to Time.zone.local(2018, 10, 30)
        report = FirstTimeVsReturningSales.new(
          group_by: 'day_of_week',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(3, report.results.length)

        assert_equal(7, report.results.first['_id']['day_of_week'])
        assert_equal(1, report.results.first['orders'])
        assert_equal(0, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(100.000, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.first['starts_at'])

        assert_equal(2, report.results.second['_id']['day_of_week'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(2, report.results.second['first_time_orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_in_delta(33.333, report.results.second['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.second['starts_at'])

        assert_equal(1, report.results.third['_id']['day_of_week'])
        assert_equal(2, report.results.third['orders'])
        assert_equal(1, report.results.third['first_time_orders'])
        assert_equal(1, report.results.third['returning_orders'])
        assert_in_delta(50.000, report.results.third['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.third['starts_at'])
      end

      def test_week
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 27), orders: 1, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 28), orders: 2, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 3, returning_orders: 1)

        travel_to Time.zone.local(2018, 10, 30)
        report = FirstTimeVsReturningSales.new(
          group_by: 'week',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(44, report.results.first['_id']['week'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(2, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(33.333, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(43, report.results.second['_id']['week'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(1, report.results.second['first_time_orders'])
        assert_equal(2, report.results.second['returning_orders'])
        assert_in_delta(66.666, report.results.second['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.second['starts_at'])
      end

      def test_month
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 1, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 30), orders: 2, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 11, 1), orders: 3, returning_orders: 1)

        travel_to Time.zone.local(2018, 11, 2)
        report = FirstTimeVsReturningSales.new(
          group_by: 'month',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(11, report.results.first['_id']['month'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(2, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(33.333, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2018, 11, 1), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(1, report.results.second['first_time_orders'])
        assert_equal(2, report.results.second['returning_orders'])
        assert_in_delta(66.666, report.results.second['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.second['starts_at'])
      end

      def test_quarter
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 1, 1), orders: 1, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 4, 1), orders: 2, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 7, 1), orders: 3, returning_orders: 1)

        travel_to Time.zone.local(2018, 10, 1)
        report = FirstTimeVsReturningSales.new(
          starts_at: 2.years.ago,
          group_by: 'quarter',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(3, report.results.first['_id']['quarter'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(2, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(33.333, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2018, 7, 1), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(2, report.results.second['_id']['quarter'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(1, report.results.second['first_time_orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_in_delta(50.000, report.results.second['percent_returning'])
        assert_equal(Time.zone.local(2018, 4, 1), report.results.second['starts_at'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(1, report.results.third['_id']['quarter'])
        assert_equal(1, report.results.third['orders'])
        assert_equal(0, report.results.third['first_time_orders'])
        assert_equal(1, report.results.third['returning_orders'])
        assert_in_delta(100.000, report.results.third['percent_returning'])
        assert_equal(Time.zone.local(2018, 1, 1), report.results.third['starts_at'])
      end

      def test_year
        Metrics::SalesByDay.inc(at: Time.zone.local(2016, 1, 1), orders: 2, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2017, 1, 1), orders: 3, returning_orders: 1)

        travel_to Time.zone.local(2018, 1, 1)
        report = FirstTimeVsReturningSales.new(
          starts_at: 2.years.ago,
          group_by: 'year',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2017, report.results.first['_id']['year'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(2, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(33.333, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2017, 1, 1), report.results.first['starts_at'])

        assert_equal(2016, report.results.second['_id']['year'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(1, report.results.second['first_time_orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_in_delta(50.000, report.results.second['percent_returning'])
        assert_equal(Time.zone.local(2016, 1, 1), report.results.second['starts_at'])
      end

      def test_date_ranges
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 27), orders: 1, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 28), orders: 2, returning_orders: 1)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 3, returning_orders: 1)

        report = FirstTimeVsReturningSales.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-28'
        )

        assert_equal(1, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(28, report.results.first['_id']['day'])
        assert_equal(2, report.results.first['orders'])
        assert_equal(1, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(50.000, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.first['starts_at'])

        report = FirstTimeVsReturningSales.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-29'
        )

        assert_equal(2, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(2, report.results.first['first_time_orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_in_delta(33.333, report.results.first['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(1, report.results.second['first_time_orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_in_delta(50.000, report.results.second['percent_returning'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])
      end
    end
  end
end
