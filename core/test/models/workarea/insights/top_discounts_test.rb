require 'test_helper'

module Workarea
  module Insights
    class TopDiscountsTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::DiscountByDay.inc(
          key: { discount_id: 'foo' },
          at: Time.zone.local(2018, 10, 27),
          revenue: 10.to_m,
          orders: 1
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'foo' },
          at: Time.zone.local(2018, 10, 28),
          revenue: 15.to_m,
          orders: 2
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'foo' },
          at: Time.zone.local(2018, 10, 29),
          revenue: 27.to_m,
          orders: 4
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'bar' },
          at: Time.zone.local(2018, 10, 27),
          revenue: 11.to_m,
          orders: 1
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'bar' },
          at: Time.zone.local(2018, 10, 28),
          revenue: 15.to_m,
          orders: 1
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'bar' },
          at: Time.zone.local(2018, 10, 29),
          revenue: 35.to_m,
          orders: 3
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 27),
          orders: 25
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 28),
          orders: 35
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 29),
          orders: 65
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 11, 1)
      end

      def test_generate_monthly!
        TopDiscounts.generate_monthly!
        assert_equal(1, TopDiscounts.count)

        top_discounts = TopDiscounts.first
        assert_equal(2, top_discounts.results.size)
        assert_equal('bar', top_discounts.results.first['discount_id'])
        assert_in_delta(4.0, top_discounts.results.first['percent_of_total'])
        assert_equal('foo', top_discounts.results.second['discount_id'])
        assert_in_delta(5.6, top_discounts.results.second['percent_of_total'])
      end

      def test_find_total_orders
        assert_equal(125, TopDiscounts.find_total_orders)

        Metrics::SalesByDay.delete_all
        assert_equal(0, TopDiscounts.find_total_orders)
      end
    end
  end
end
