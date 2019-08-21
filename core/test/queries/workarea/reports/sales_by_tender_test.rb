require 'test_helper'

module Workarea
  module Reports
    class SalesByTenderTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::TenderByDay.inc(
          key: { tender: 'credit_card' },
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          revenue: 10.to_m
        )

        Metrics::TenderByDay.inc(
          key: { tender: 'credit_card' },
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          revenue: 15.to_m
        )

        Metrics::TenderByDay.inc(
          key: { tender: 'credit_card' },
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          revenue: 27.to_m
        )

        Metrics::TenderByDay.inc(
          key: { tender: 'store_credit' },
          at: Time.zone.local(2018, 10, 27),
          orders: 2,
          revenue: 11.to_m
        )

        Metrics::TenderByDay.inc(
          key: { tender: 'store_credit' },
          at: Time.zone.local(2018, 10, 28),
          orders: 3,
          revenue: 15.to_m
        )

        Metrics::TenderByDay.inc(
          key: { tender: 'store_credit' },
          at: Time.zone.local(2018, 10, 29),
          orders: 4,
          revenue: 27.to_m
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 10, 30)
      end

      def test_grouping_and_summing
        report = SalesByTender.new
        assert_equal(2, report.results.length)

        credit_card = report.results.detect { |r| r['_id'] == 'credit_card' }
        assert_equal(6, credit_card['orders'])
        assert_equal(52, credit_card['revenue'])

        store_credit = report.results.detect { |r| r['_id'] == 'store_credit' }
        assert_equal(9, store_credit['orders'])
        assert_equal(53, store_credit['revenue'])
      end

      def test_date_ranges
        report = SalesByTender.new
        credit_card = report.results.detect { |r| r['_id'] == 'credit_card' }
        assert_equal(6, credit_card['orders'])

        report = SalesByTender.new(starts_at: '2018-10-28', ends_at: '2018-10-28')
        credit_card = report.results.detect { |r| r['_id'] == 'credit_card' }
        assert_equal(2, credit_card['orders'])

        report = SalesByTender.new(starts_at: '2018-10-28', ends_at: '2018-10-29')
        credit_card = report.results.detect { |r| r['_id'] == 'credit_card' }
        assert_equal(5, credit_card['orders'])

        report = SalesByTender.new(starts_at: '2018-10-28')
        credit_card = report.results.detect { |r| r['_id'] == 'credit_card' }
        assert_equal(5, credit_card['orders'])

        report = SalesByTender.new(ends_at: '2018-10-28')
        credit_card = report.results.detect { |r| r['_id'] == 'credit_card' }
        assert_equal(3, credit_card['orders'])
      end

      def test_sorting
        report = SalesByTender.new(sort_by: 'orders', sort_direction: 'asc')
        assert_equal('credit_card', report.results.first['_id'])

        report = SalesByTender.new(sort_by: 'orders', sort_direction: 'desc')
        assert_equal('store_credit', report.results.first['_id'])
      end
    end
  end
end
