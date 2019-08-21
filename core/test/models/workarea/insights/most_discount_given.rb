require 'test_helper'

module Workarea
  module Insights
    class MostDiscountGivenTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::DiscountByDay.inc(
          key: { discount_id: 'foo' },
          at: Time.zone.local(2018, 10, 27),
          discounts: -10.to_m
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'foo' },
          at: Time.zone.local(2018, 10, 28),
          discounts: -15.to_m
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'foo' },
          at: Time.zone.local(2018, 10, 29),
          discounts: -27.to_m
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'bar' },
          at: Time.zone.local(2018, 10, 27),
          discounts: -11.to_m
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'bar' },
          at: Time.zone.local(2018, 10, 28),
          discounts: -15.to_m
        )

        Metrics::DiscountByDay.inc(
          key: { discount_id: 'bar' },
          at: Time.zone.local(2018, 10, 29),
          discounts: -35.to_m
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 11, 1)
      end

      def test_generate_monthly!
        MostDiscountGiven.generate_monthly!
        assert_equal(1, MostDiscountGiven.count)

        top_discounts = MostDiscountGiven.first
        assert_equal(2, top_discounts.results.size)
        assert_equal('bar', top_discounts.results.first['discount_id'])
        assert_in_delta(53.982, top_discounts.results.first['percent_of_total'])
        assert_equal('foo', top_discounts.results.second['discount_id'])
        assert_in_delta(46.018, top_discounts.results.second['percent_of_total'])
      end

      def test_find_total_orders
        assert_equal(-113, MostDiscountGiven.find_total_discount)

        Metrics::DiscountByDay.delete_all
        assert_equal(0, MostDiscountGiven.find_total_discount)
      end
    end
  end
end
