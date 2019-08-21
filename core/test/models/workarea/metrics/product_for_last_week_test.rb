require 'test_helper'

module Workarea
  module Metrics
    class ProductForLastWeekTest < TestCase
      def test_aggregate_last_week!
        create_product_by_week(
          product_id: 'foo',
          revenue: 40.to_m,
          reporting_on: Time.zone.local(2018, 10, 20)
        )

        ProductByDay.inc(
          key: { product_id: 'foo' },
          at: Time.zone.local(2018, 10, 27),
          views: 10,
          orders: 1,
          units_sold: 2,
          discounted_units_sold: 1,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        ProductByDay.inc(
          key: { product_id: 'foo' },
          at: Time.zone.local(2018, 10, 28),
          views: 20,
          orders: 2,
          units_sold: 4,
          discounted_units_sold: 2,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        ProductByDay.inc(
          key: { product_id: 'foo' },
          at: Time.zone.local(2018, 10, 29),
          views: 30,
          orders: 3,
          units_sold: 6,
          discounted_units_sold: 3,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        ProductByDay.inc(
          key: { product_id: 'bar' },
          at: Time.zone.local(2018, 10, 27),
          views: 10,
          orders: 2,
          units_sold: 3,
          discounted_units_sold: 3,
          merchandise: 11.to_m,
          discounts: 0.to_m,
          revenue: 11.to_m
        )

        ProductByDay.inc(
          key: { product_id: 'bar' },
          at: Time.zone.local(2018, 10, 28),
          views: 15,
          orders: 3,
          units_sold: 5,
          discounted_units_sold: 4,
          merchandise: 21.to_m,
          discounts: -6.to_m,
          revenue: 15.to_m
        )

        ProductByDay.inc(
          key: { product_id: 'bar' },
          at: Time.zone.local(2018, 10, 29),
          views: 20,
          orders: 4,
          units_sold: 7,
          discounted_units_sold: 5,
          merchandise: 31.to_m,
          discounts: -4.to_m,
          revenue: 27.to_m
        )

        travel_to Time.zone.local(2018, 10, 30)
        ProductForLastWeek.aggregate!

        assert_equal(2, ProductForLastWeek.count)

        foo = ProductForLastWeek.find_by(product_id: 'foo')
        assert_equal('20181027-foo', foo.id)
        assert_equal(30, foo.views)
        assert_equal(100, foo.views_percentile)
        assert_equal(3, foo.orders)
        assert_equal(6, foo.units_sold)
        assert_equal(3, foo.discounted_units_sold)
        assert_equal(30, foo.merchandise)
        assert_equal(-5, foo.discounts)
        assert_equal(0, foo.tax)
        assert_equal(25, foo.revenue)
        assert_equal(40, foo.prior_week_revenue)
        assert_equal(-15, foo.revenue_change)
        assert_in_delta(0.1666, foo.average_discount)
        assert_in_delta(50, foo.discount_rate)
        assert_in_delta(10, foo.conversion_rate)
        assert_kind_of(Time, foo.reporting_on)

        bar = ProductForLastWeek.find_by(product_id: 'bar')
        assert_equal('20181027-bar', bar.id)
        assert_equal(25, bar.views)
        assert_equal(50, bar.views_percentile)
        assert_equal(5, bar.orders)
        assert_equal(8, bar.units_sold)
        assert_equal(7, bar.discounted_units_sold)
        assert_equal(32, bar.merchandise)
        assert_equal(-6, bar.discounts)
        assert_equal(0, bar.tax)
        assert_equal(26, bar.revenue)
        assert_equal(0, bar.prior_week_revenue)
        assert_equal(26, bar.revenue_change)
        assert_in_delta(0.1875, bar.average_discount)
        assert_in_delta(87.5, bar.discount_rate)
        assert_in_delta(20, bar.conversion_rate)
        assert_kind_of(Time, bar.reporting_on)
      end
    end
  end
end
