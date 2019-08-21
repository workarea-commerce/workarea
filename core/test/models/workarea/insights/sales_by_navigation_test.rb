require 'test_helper'

module Workarea
  module Insights
    class SalesByNavigationTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::MenuByDay.inc(
          key: { menu_id: 'foo' },
          at: Time.zone.local(2018, 10, 27),
          revenue: 10.to_m,
          orders: 1
        )

        Metrics::MenuByDay.inc(
          key: { menu_id: 'foo' },
          at: Time.zone.local(2018, 10, 28),
          revenue: 15.to_m,
          orders: 1
        )

        Metrics::MenuByDay.inc(
          key: { menu_id: 'foo' },
          at: Time.zone.local(2018, 10, 29),
          revenue: 27.to_m,
          orders: 1
        )

        Metrics::MenuByDay.inc(
          key: { menu_id: 'bar' },
          at: Time.zone.local(2018, 10, 27),
          revenue: 11.to_m,
          orders: 1
        )

        Metrics::MenuByDay.inc(
          key: { menu_id: 'bar' },
          at: Time.zone.local(2018, 10, 28),
          revenue: 15.to_m,
          orders: 1
        )

        Metrics::MenuByDay.inc(
          key: { menu_id: 'bar' },
          at: Time.zone.local(2018, 10, 29),
          revenue: 35.to_m,
          orders: 1
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 27),
          revenue: 25.to_m,
          orders: 1
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 28),
          revenue: 35.to_m,
          orders: 1
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          revenue: 65.to_m,
          orders: 1
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 11, 1)
      end

      def test_generate_monthly!
        SalesByNavigation.generate_monthly!
        assert_equal(1, SalesByNavigation.count)

        sales_by_navigation = SalesByNavigation.first
        assert_equal(2, sales_by_navigation.results.size)
        assert_equal('bar', sales_by_navigation.results.first['menu_id'])
        assert_in_delta(48.8, sales_by_navigation.results.first['percent_of_total'])
        assert_equal('foo', sales_by_navigation.results.second['menu_id'])
        assert_in_delta(41.6, sales_by_navigation.results.second['percent_of_total'])
      end

      def test_find_total_revenue
        assert_equal(125, SalesByNavigation.find_total_revenue)

        Metrics::SalesByDay.delete_all
        assert_equal(0, SalesByNavigation.find_total_revenue)
      end
    end
  end
end
