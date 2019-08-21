require 'test_helper'

module Workarea
  module Reports
    class SalesOverTimeTest < TestCase
      def test_by_day
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          returning_orders: 0,
          customers: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          returning_orders: 1,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)
        report = SalesOverTime.new(group_by: 'day', sort_by: '_id', sort_direction: 'desc')

        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_equal(2, report.results.first['customers'])
        assert_equal(6, report.results.first['units_sold'])
        assert_equal(30, report.results.first['merchandise'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(-3, report.results.first['discounts'])
        assert_equal(9, report.results.first['aov'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_equal(2, report.results.second['customers'])
        assert_equal(4, report.results.second['units_sold'])
        assert_equal(20, report.results.second['merchandise'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(-5, report.results.second['discounts'])
        assert_equal(7.5, report.results.second['aov'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(10, report.results.third['_id']['month'])
        assert_equal(27, report.results.third['_id']['day'])
        assert_equal(1, report.results.third['orders'])
        assert_equal(0, report.results.third['returning_orders'])
        assert_equal(1, report.results.third['customers'])
        assert_equal(2, report.results.third['units_sold'])
        assert_equal(10, report.results.third['merchandise'])
        assert_equal(10, report.results.third['revenue'])
        assert_equal(0, report.results.third['discounts'])
        assert_equal(10, report.results.third['aov'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.third['starts_at'])

        report = SalesOverTime.new(group_by: 'day', sort_by: '_id', sort_direction: 'asc')
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
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          returning_orders: 0,
          customers: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          returning_orders: 1,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)
        report = SalesOverTime.new(
          group_by: 'day_of_week',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(3, report.results.length)

        assert_equal(7, report.results.first['_id']['day_of_week'])
        assert_equal(1, report.results.first['orders'])
        assert_equal(0, report.results.first['returning_orders'])
        assert_equal(1, report.results.first['customers'])
        assert_equal(2, report.results.first['units_sold'])
        assert_equal(10, report.results.first['merchandise'])
        assert_equal(10, report.results.first['revenue'])
        assert_equal(0, report.results.first['discounts'])
        assert_equal(10, report.results.first['aov'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.first['starts_at'])

        assert_equal(2, report.results.second['_id']['day_of_week'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_equal(2, report.results.second['customers'])
        assert_equal(6, report.results.second['units_sold'])
        assert_equal(30, report.results.second['merchandise'])
        assert_equal(27, report.results.second['revenue'])
        assert_equal(-3, report.results.second['discounts'])
        assert_equal(9, report.results.second['aov'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.second['starts_at'])

        assert_equal(1, report.results.third['_id']['day_of_week'])
        assert_equal(2, report.results.third['orders'])
        assert_equal(1, report.results.third['returning_orders'])
        assert_equal(2, report.results.third['customers'])
        assert_equal(4, report.results.third['units_sold'])
        assert_equal(20, report.results.third['merchandise'])
        assert_equal(15, report.results.third['revenue'])
        assert_equal(-5, report.results.third['discounts'])
        assert_equal(7.5, report.results.third['aov'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.third['starts_at'])
      end

      def test_week
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          returning_orders: 0,
          customers: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          returning_orders: 1,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)
        report = SalesOverTime.new(
          group_by: 'week',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(44, report.results.first['_id']['week'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_equal(2, report.results.first['customers'])
        assert_equal(6, report.results.first['units_sold'])
        assert_equal(30, report.results.first['merchandise'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(-3, report.results.first['discounts'])
        assert_equal(9, report.results.first['aov'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(43, report.results.second['_id']['week'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_equal(3, report.results.second['customers'])
        assert_equal(6, report.results.second['units_sold'])
        assert_equal(30, report.results.second['merchandise'])
        assert_equal(25, report.results.second['revenue'])
        assert_equal(-5, report.results.second['discounts'])
        assert_in_delta(8.333, report.results.second['aov'])
        assert_equal(Time.zone.local(2018, 10, 27), report.results.second['starts_at'])
      end

      def test_month
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          orders: 1,
          returning_orders: 0,
          customers: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 30),
          orders: 2,
          returning_orders: 1,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 11, 1),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 11, 2)
        report = SalesOverTime.new(
          group_by: 'month',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(11, report.results.first['_id']['month'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_equal(2, report.results.first['customers'])
        assert_equal(6, report.results.first['units_sold'])
        assert_equal(30, report.results.first['merchandise'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(-3, report.results.first['discounts'])
        assert_equal(9, report.results.first['aov'])
        assert_equal(Time.zone.local(2018, 11, 1), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(3, report.results.second['orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_equal(3, report.results.second['customers'])
        assert_equal(6, report.results.second['units_sold'])
        assert_equal(30, report.results.second['merchandise'])
        assert_equal(25, report.results.second['revenue'])
        assert_equal(-5, report.results.second['discounts'])
        assert_in_delta(8.333, report.results.second['aov'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.second['starts_at'])
      end

      def test_quarter
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 1, 1),
          orders: 1,
          returning_orders: 0,
          customers: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 4, 1),
          orders: 2,
          returning_orders: 1,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 7, 1),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 10, 1)
        report = SalesOverTime.new(
          starts_at: 2.years.ago,
          group_by: 'quarter',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(3, report.results.length)

        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(3, report.results.first['_id']['quarter'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_equal(2, report.results.first['customers'])
        assert_equal(6, report.results.first['units_sold'])
        assert_equal(30, report.results.first['merchandise'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(-3, report.results.first['discounts'])
        assert_equal(9, report.results.first['aov'])
        assert_equal(Time.zone.local(2018, 7, 1), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(2, report.results.second['_id']['quarter'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_equal(2, report.results.second['customers'])
        assert_equal(4, report.results.second['units_sold'])
        assert_equal(20, report.results.second['merchandise'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(-5, report.results.second['discounts'])
        assert_equal(7.5, report.results.second['aov'])
        assert_equal(Time.zone.local(2018, 4, 1), report.results.second['starts_at'])

        assert_equal(2018, report.results.third['_id']['year'])
        assert_equal(1, report.results.third['_id']['quarter'])
        assert_equal(1, report.results.third['orders'])
        assert_equal(0, report.results.third['returning_orders'])
        assert_equal(1, report.results.third['customers'])
        assert_equal(2, report.results.third['units_sold'])
        assert_equal(10, report.results.third['merchandise'])
        assert_equal(10, report.results.third['revenue'])
        assert_equal(0, report.results.third['discounts'])
        assert_equal(10, report.results.third['aov'])
        assert_equal(Time.zone.local(2018, 1, 1), report.results.third['starts_at'])
      end

      def test_year
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2016, 1, 1),
          orders: 2,
          returning_orders: 0,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2017, 1, 1),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 1, 1)
        report = SalesOverTime.new(
          starts_at: 2.years.ago,
          group_by: 'year',
          sort_by: '_id',
          sort_direction: 'desc'
        )

        assert_equal(2, report.results.length)

        assert_equal(2017, report.results.first['_id']['year'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_equal(2, report.results.first['customers'])
        assert_equal(6, report.results.first['units_sold'])
        assert_equal(30, report.results.first['merchandise'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(-3, report.results.first['discounts'])
        assert_equal(9, report.results.first['aov'])
        assert_equal(Time.zone.local(2017, 1, 1), report.results.first['starts_at'])

        assert_equal(2016, report.results.second['_id']['year'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(0, report.results.second['returning_orders'])
        assert_equal(2, report.results.second['customers'])
        assert_equal(4, report.results.second['units_sold'])
        assert_equal(20, report.results.second['merchandise'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(-5, report.results.second['discounts'])
        assert_equal(7.5, report.results.second['aov'])
        assert_equal(Time.zone.local(2016, 1, 1), report.results.second['starts_at'])
      end

      def test_date_ranges
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          returning_orders: 0,
          customers: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          returning_orders: 1,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        report = SalesOverTime.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-28'
        )

        assert_equal(1, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(28, report.results.first['_id']['day'])
        assert_equal(2, report.results.first['orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_equal(2, report.results.first['customers'])
        assert_equal(4, report.results.first['units_sold'])
        assert_equal(20, report.results.first['merchandise'])
        assert_equal(15, report.results.first['revenue'])
        assert_equal(-5, report.results.first['discounts'])
        assert_equal(7.5, report.results.first['aov'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.first['starts_at'])

        report = SalesOverTime.new(
          group_by: 'day',
          starts_at: '2018-10-28',
          ends_at: '2018-10-29'
        )

        assert_equal(2, report.results.size)
        assert_equal(2018, report.results.first['_id']['year'])
        assert_equal(10, report.results.first['_id']['month'])
        assert_equal(29, report.results.first['_id']['day'])
        assert_equal(3, report.results.first['orders'])
        assert_equal(1, report.results.first['returning_orders'])
        assert_equal(2, report.results.first['customers'])
        assert_equal(6, report.results.first['units_sold'])
        assert_equal(30, report.results.first['merchandise'])
        assert_equal(27, report.results.first['revenue'])
        assert_equal(-3, report.results.first['discounts'])
        assert_equal(9, report.results.first['aov'])
        assert_equal(Time.zone.local(2018, 10, 29), report.results.first['starts_at'])

        assert_equal(2018, report.results.second['_id']['year'])
        assert_equal(10, report.results.second['_id']['month'])
        assert_equal(28, report.results.second['_id']['day'])
        assert_equal(2, report.results.second['orders'])
        assert_equal(1, report.results.second['returning_orders'])
        assert_equal(2, report.results.second['customers'])
        assert_equal(4, report.results.second['units_sold'])
        assert_equal(20, report.results.second['merchandise'])
        assert_equal(15, report.results.second['revenue'])
        assert_equal(-5, report.results.second['discounts'])
        assert_equal(7.5, report.results.second['aov'])
        assert_equal(Time.zone.local(2018, 10, 28), report.results.second['starts_at'])
      end
    end
  end
end
