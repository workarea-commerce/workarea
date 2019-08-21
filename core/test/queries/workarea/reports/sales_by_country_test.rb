require 'test_helper'

module Workarea
  module Reports
    class SalesByCountryTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::CountryByDay.inc(
          key: { country: 'US' },
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::CountryByDay.inc(
          key: { country: 'US' },
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m,
          units_canceled: 2,
          refund: -10.to_m,
          cancellations: 1
        )

        Metrics::CountryByDay.inc(
          key: { country: 'US' },
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m,
          units_canceled: 1,
          refund: -3.to_m,
          cancellations: 1
        )

        Metrics::CountryByDay.inc(
          key: { country: 'CA' },
          at: Time.zone.local(2018, 10, 27),
          orders: 2,
          units_sold: 3,
          merchandise: 11.to_m,
          discounts: 0.to_m,
          revenue: 11.to_m,
          units_canceled: 1,
          refund: -5.to_m,
          cancellations: 1
        )

        Metrics::CountryByDay.inc(
          key: { country: 'CA' },
          at: Time.zone.local(2018, 10, 28),
          orders: 3,
          units_sold: 5,
          merchandise: 21.to_m,
          discounts: -6.to_m,
          revenue: 15.to_m
        )

        Metrics::CountryByDay.inc(
          key: { country: 'CA' },
          at: Time.zone.local(2018, 10, 29),
          orders: 4,
          units_sold: 7,
          merchandise: 31.to_m,
          discounts: -4.to_m,
          revenue: 27.to_m
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 10, 30)
      end

      def test_grouping_and_summing
        report = SalesByCountry.new
        assert_equal(2, report.results.length)

        us = report.results.detect { |r| r['_id'] == 'US' }
        assert_equal(6, us['orders'])
        assert_equal(12, us['units_sold'])
        assert_equal(60, us['merchandise'])
        assert_equal(-8, us['discounts'])
        assert_equal(52, us['revenue'])
        assert_equal(2, us['cancellations'])
        assert_equal(3, us['units_canceled'])
        assert_equal(-13, us['refund'])

        ca = report.results.detect { |r| r['_id'] == 'CA' }
        assert_equal(9, ca['orders'])
        assert_equal(15, ca['units_sold'])
        assert_equal(63, ca['merchandise'])
        assert_equal(-10, ca['discounts'])
        assert_equal(53, ca['revenue'])
        assert_equal(1, ca['cancellations'])
        assert_equal(1, ca['units_canceled'])
        assert_equal(-5, ca['refund'])
      end

      def test_date_ranges
        report = SalesByCountry.new
        us = report.results.detect { |r| r['_id'] == 'US' }
        assert_equal(6, us['orders'])

        report = SalesByCountry.new(starts_at: '2018-10-28', ends_at: '2018-10-28')
        us = report.results.detect { |r| r['_id'] == 'US' }
        assert_equal(2, us['orders'])

        report = SalesByCountry.new(starts_at: '2018-10-28', ends_at: '2018-10-29')
        us = report.results.detect { |r| r['_id'] == 'US' }
        assert_equal(5, us['orders'])

        report = SalesByCountry.new(starts_at: '2018-10-28')
        us = report.results.detect { |r| r['_id'] == 'US' }
        assert_equal(5, us['orders'])

        report = SalesByCountry.new(ends_at: '2018-10-28')
        us = report.results.detect { |r| r['_id'] == 'US' }
        assert_equal(3, us['orders'])
      end

      def test_sorting
        report = SalesByCountry.new(sort_by: 'orders', sort_direction: 'asc')
        assert_equal('US', report.results.first['_id'])

        report = SalesByCountry.new(sort_by: 'orders', sort_direction: 'desc')
        assert_equal('CA', report.results.first['_id'])

        report = SalesByCountry.new(sort_by: 'discounts', sort_direction: 'asc')
        assert_equal('CA', report.results.first['_id'])

        report = SalesByCountry.new(sort_by: 'discounts', sort_direction: 'desc')
        assert_equal('US', report.results.first['_id'])
      end
    end
  end
end
