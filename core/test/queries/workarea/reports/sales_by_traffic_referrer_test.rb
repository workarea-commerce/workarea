require 'test_helper'

module Workarea
  module Reports
    class SalesByTrafficReferrerTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'search', source: 'Google' },
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'search', source: 'Google' },
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'search', source: 'Google' },
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'social', source: 'Facebook' },
          at: Time.zone.local(2018, 10, 27),
          orders: 2,
          units_sold: 3,
          merchandise: 11.to_m,
          discounts: 0.to_m,
          revenue: 11.to_m
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'social', source: 'Facebook' },
          at: Time.zone.local(2018, 10, 28),
          orders: 3,
          units_sold: 5,
          merchandise: 21.to_m,
          discounts: -6.to_m,
          revenue: 15.to_m
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'social', source: 'Facebook' },
          at: Time.zone.local(2018, 10, 29),
          orders: 4,
          units_sold: 7,
          merchandise: 31.to_m,
          discounts: -4.to_m,
          revenue: 27.to_m
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'social', source: 'Twitter' },
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          units_sold: 3,
          merchandise: 30.to_m,
          discounts: 0.to_m,
          revenue: 30.to_m
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 10, 30)
      end

      def test_grouping_and_summing
        report = SalesByTrafficReferrer.new
        assert_equal(3, report.results.length)

        google = report.results.detect { |r| r['_id']['source'] == 'Google' }
        assert_equal(6, google['orders'])
        assert_equal(12, google['units_sold'])
        assert_equal(60, google['merchandise'])
        assert_equal(-8, google['discounts'])
        assert_equal(52, google['revenue'])

        facebook = report.results.detect { |r| r['_id']['source'] == 'Facebook' }
        assert_equal(9, facebook['orders'])
        assert_equal(15, facebook['units_sold'])
        assert_equal(63, facebook['merchandise'])
        assert_equal(-10, facebook['discounts'])
        assert_equal(53, facebook['revenue'])

        twitter = report.results.detect { |r| r['_id']['source'] == 'Twitter' }
        assert_equal(3, twitter['orders'])
        assert_equal(3, twitter['units_sold'])
        assert_equal(30, twitter['merchandise'])
        assert_equal(0, twitter['discounts'])
        assert_equal(30, twitter['revenue'])
      end

      def test_date_ranges
        report = SalesByTrafficReferrer.new
        google = report.results.detect { |r| r['_id']['source'] == 'Google' }
        assert_equal(6, google['orders'])

        report = SalesByTrafficReferrer.new(starts_at: '2018-10-28', ends_at: '2018-10-28')
        google = report.results.detect { |r| r['_id']['source'] == 'Google' }
        assert_equal(2, google['orders'])

        report = SalesByTrafficReferrer.new(starts_at: '2018-10-28', ends_at: '2018-10-29')
        google = report.results.detect { |r| r['_id']['source'] == 'Google' }
        assert_equal(5, google['orders'])

        report = SalesByTrafficReferrer.new(starts_at: '2018-10-28')
        google = report.results.detect { |r| r['_id']['source'] == 'Google' }
        assert_equal(5, google['orders'])

        report = SalesByTrafficReferrer.new(ends_at: '2018-10-28')
        google = report.results.detect { |r| r['_id']['source'] == 'Google' }
        assert_equal(3, google['orders'])
      end

      def test_sorting
        report = SalesByTrafficReferrer.new(sort_by: 'orders', sort_direction: 'asc')
        assert_equal('Twitter', report.results.first['_id']['source'])

        report = SalesByTrafficReferrer.new(sort_by: 'orders', sort_direction: 'desc')
        assert_equal('Facebook', report.results.first['_id']['source'])

        report = SalesByTrafficReferrer.new(sort_by: 'discounts', sort_direction: 'asc')
        assert_equal('Facebook', report.results.first['_id']['source'])

        report = SalesByTrafficReferrer.new(sort_by: 'discounts', sort_direction: 'desc')
        assert_equal('Twitter', report.results.first['_id']['source'])

        report = SalesByTrafficReferrer.new(sort_by: '_id.medium', sort_direction: 'asc')
        assert_equal('search', report.results.first['_id']['medium'])

        report = SalesByTrafficReferrer.new(sort_by: '_id.medium', sort_direction: 'desc')
        assert_equal('social', report.results.first['_id']['medium'])

        report = SalesByTrafficReferrer.new(sort_by: '_id.source', sort_direction: 'asc')
        assert_equal('Facebook', report.results.first['_id']['source'])

        report = SalesByTrafficReferrer.new(sort_by: '_id.source', sort_direction: 'desc')
        assert_equal('Twitter', report.results.first['_id']['source'])
      end
    end
  end
end
