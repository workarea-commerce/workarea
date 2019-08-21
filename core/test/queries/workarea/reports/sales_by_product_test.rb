require 'test_helper'

module Workarea
  module Reports
    class SalesByProductTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::ProductByDay.inc(
          key: { product_id: 'foo' },
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          tax: 1.to_m,
          revenue: 11.to_m
        )

        Metrics::ProductByDay.inc(
          key: { product_id: 'foo' },
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          tax: 1.to_m,
          revenue: 16.to_m,
          units_canceled: 2,
          refund: -10.to_m
        )

        Metrics::ProductByDay.inc(
          key: { product_id: 'foo' },
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          tax: 2.to_m,
          revenue: 29.to_m,
          units_canceled: 1,
          refund: -3.to_m
        )

        Metrics::ProductByDay.inc(
          key: { product_id: 'bar' },
          at: Time.zone.local(2018, 10, 27),
          orders: 2,
          units_sold: 3,
          merchandise: 11.to_m,
          discounts: 0.to_m,
          tax: 1.to_m,
          revenue: 12.to_m,
          units_canceled: 1,
          refund: -5.to_m
        )

        Metrics::ProductByDay.inc(
          key: { product_id: 'bar' },
          at: Time.zone.local(2018, 10, 28),
          orders: 3,
          units_sold: 5,
          merchandise: 21.to_m,
          discounts: -6.to_m,
          tax: 1.to_m,
          revenue: 16.to_m
        )

        Metrics::ProductByDay.inc(
          key: { product_id: 'bar' },
          at: Time.zone.local(2018, 10, 29),
          orders: 4,
          units_sold: 7,
          merchandise: 31.to_m,
          discounts: -4.to_m,
          tax: 2.to_m,
          revenue: 29.to_m
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 10, 30)
      end

      def test_grouping_and_summing
        report = SalesByProduct.new
        assert_equal(2, report.results.length)

        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(6, foo['orders'])
        assert_equal(12, foo['units_sold'])
        assert_equal(60, foo['merchandise'])
        assert_equal(-8, foo['discounts'])
        assert_equal(4, foo['tax'])
        assert_equal(56, foo['revenue'])
        assert_equal(4.33, foo['average_price'])
        assert_equal(3, foo['units_canceled'])
        assert_equal(-13, foo['refund'])

        bar = report.results.detect { |r| r['_id'] == 'bar' }
        assert_equal(9, bar['orders'])
        assert_equal(15, bar['units_sold'])
        assert_equal(63, bar['merchandise'])
        assert_equal(-10, bar['discounts'])
        assert_equal(4, bar['tax'])
        assert_equal(57, bar['revenue'])
        assert_equal(3.53, bar['average_price'])
        assert_equal(1, bar['units_canceled'])
        assert_equal(-5, bar['refund'])
      end

      def test_date_ranges
        report = SalesByProduct.new
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(6, foo['orders'])

        report = SalesByProduct.new(starts_at: '2018-10-28', ends_at: '2018-10-28')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(2, foo['orders'])

        report = SalesByProduct.new(starts_at: '2018-10-28', ends_at: '2018-10-29')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(5, foo['orders'])

        report = SalesByProduct.new(starts_at: '2018-10-28')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(5, foo['orders'])

        report = SalesByProduct.new(ends_at: '2018-10-28')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(3, foo['orders'])
      end

      def test_sorting
        report = SalesByProduct.new(sort_by: 'orders', sort_direction: 'asc')
        assert_equal('foo', report.results.first['_id'])

        report = SalesByProduct.new(sort_by: 'orders', sort_direction: 'desc')
        assert_equal('bar', report.results.first['_id'])

        report = SalesByProduct.new(sort_by: 'discounts', sort_direction: 'asc')
        assert_equal('bar', report.results.first['_id'])

        report = SalesByProduct.new(sort_by: 'discounts', sort_direction: 'desc')
        assert_equal('foo', report.results.first['_id'])
      end
    end
  end
end
