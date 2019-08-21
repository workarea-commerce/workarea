require 'test_helper'

module Workarea
  module Reports
    class AverageOrderValueTest < TestCase
      def test_by_day
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 27), orders: 1, revenue: 10.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 28), orders: 2, revenue: 15.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 3, revenue: 27.to_m)

        travel_to Time.zone.local(2018, 10, 30)
        report = AverageOrderValue.new(group_by: 'day', sort_by: '_id', sort_direction: 'desc')

        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(9, report.results.first['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(7.5, report.results.second['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(10, report.results.third['_id']['month'])
        assert_equal(27, report.results.third['_id']['day'])
        assert_equal(1, report.results.third['orders'])
        assert_equal(10, report.results.third['revenue'])
        assert_equal(10, report.results.third['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.third['starts_at'])

        report = AverageOrderValue.new(group_by: 'day', sort_by: '_id', sort_direction: 'asc')
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
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 27), orders: 1, revenue: 10.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 28), orders: 2, revenue: 15.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 3, revenue: 27.to_m)

        travel_to Time.zone.local(2018, 10, 30)
        report = AverageOrderValue.new(
          group_by: 'day_of_week',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(3, report.results.length)

        assert_equal(7, report.results.first['_id']['day_of_week'])
        assert_equal(1, report.results.first['orders'])
        assert_equal(10, report.results.first['revenue'])
        assert_equal(10, report.results.first['average_order_value'])

        assert_equal(2, report.results.second['_id']['day_of_week'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(27, report.results.second['revenue'])
        assert_equal(9, report.results.second['average_order_value'])

        assert_equal(1, report.results.third['_id']['day_of_week'])
        assert_equal(2, report.results.third['orders'])
        assert_equal(15, report.results.third['revenue'])
        assert_equal(7.5, report.results.third['average_order_value'])
      end

      def test_week
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 27), orders: 1, revenue: 10.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 28), orders: 2, revenue: 15.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 3, revenue: 27.to_m)

        travel_to Time.zone.local(2018, 10, 30)
        report = AverageOrderValue.new(
          group_by: 'week',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(44, report.results.first['_id']['week'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(9, report.results.first['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(43, report.results.second['_id']['week'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(25, report.results.second['revenue'])
        assert_equal(25 / 3.to_f, report.results.second['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.second['starts_at'])
      end

      def test_month
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 29), orders: 1, revenue: 10.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 10, 30), orders: 2, revenue: 15.to_m)
        Metrics::SalesByDay.inc(at: Time.zone.local(2018, 11, 1), orders: 3, revenue: 27.to_m)

        travel_to Time.zone.local(2018, 11, 2)
        report = AverageOrderValue.new(
          group_by: 'month',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(11, report.results.first['_id']['month'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(9, report.results.first['average_order_value'])
        assert_equal(Time.zone.local(2018, 11, 1), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(25, report.results.second['revenue'])
        assert_equal(25 / 3.to_f, report.results.second['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.second['starts_at'])
      end

      def test_quarter
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 1, 1),
          orders: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 4, 1),
          orders: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 7, 1),
          orders: 3,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 10, 1)
        report = AverageOrderValue.new(
          starts_at: 2.years.ago,
          group_by: 'quarter',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(3, report.results.first['_id']['quarter'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(9, report.results.first['average_order_value'])
        assert_equal(Time.zone.local(2018, 7, 1), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(2, report.results.second['_id']['quarter'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(7.5, report.results.second['average_order_value'])
        assert_equal(Time.zone.local(2018, 4, 1), report.results.second['starts_at'])


        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(1, report.results.third['_id']['quarter'])
        assert_equal(10, report.results.third['revenue'])
        assert_equal(10, report.results.third['average_order_value'])
        assert_equal(Time.zone.local(2018, 1, 1), report.results.third['starts_at'])
      end

      def test_year
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2016, 1, 1),
          orders: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2017, 1, 1),
          orders: 3,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 1, 1)
        report = AverageOrderValue.new(
          starts_at: 2.years.ago,
          group_by: 'year',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2017, report.results.first['_id']['year'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(9, report.results.first['average_order_value'])
        assert_equal(Time.zone.local(2017, 1, 1), report.results.first['starts_at'])

        assert_equal(2016, report.results.second['_id']['year'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(7.5, report.results.second['average_order_value'])
        assert_equal(Time.zone.local(2016, 1, 1), report.results.second['starts_at'])
      end

      def test_date_ranges
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        report = AverageOrderValue.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-28'
        )

        assert_equal(1, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(28, report.results.first['_id']['day'])
        assert_equal(2, report.results.first['orders'])
        assert_equal(15, report.results.first['revenue'])
        assert_equal(7.5, report.results.first['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.first['starts_at'])

        report = AverageOrderValue.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-29'
        )

        assert_equal(2, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(9, report.results.first['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(7.5, report.results.second['average_order_value'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])
      end

      def test_zero_division
        report = AverageOrderValue.new

        Metrics::SalesByDay.create!(
          reporting_on: Time.current,
          orders: 0,
          revenue: 0
        )
        Metrics::SalesByDay.create!(
          reporting_on: Time.current,
          orders: 1,
          revenue: 0
        )
        Metrics::SalesByDay.create!(
          reporting_on: Time.current,
          orders: 0,
          revenue: 1
        )

        refute(report.results.any?)
      end
    end
  end
end
