require 'test_helper'

module Workarea
  module Reports
    class SearchesTest < TestCase
      setup :add_data, :time_travel

      def add_data
        Metrics::SearchByDay.save_search('foo', 1, at: Time.zone.local(2018, 10, 27))

        2.times do
          Metrics::SearchByDay.save_search('foo', 2, at: Time.zone.local(2018, 10, 28))
        end

        3.times do
          Metrics::SearchByDay.save_search('foo', 3, at: Time.zone.local(2018, 10, 29))
        end

        2.times do
          Metrics::SearchByDay.save_search('bar', 1, at: Time.zone.local(2018, 10, 27))
        end

        3.times do
          Metrics::SearchByDay.save_search('bar', 2, at: Time.zone.local(2018, 10, 28))
        end

        4.times do
          Metrics::SearchByDay.save_search('bar', 3, at: Time.zone.local(2018, 10, 29))
        end

        2.times do
          Metrics::SearchByDay.save_search('baz', 0, at: Time.zone.local(2018, 10, 27))
        end

        Metrics::SearchByDay.save_search('baz', 0, at: Time.zone.local(2018, 10, 28))
        Metrics::SearchByDay.save_search('qux', 0, at: Time.zone.local(2018, 10, 29))

        Metrics::SearchByDay.inc(
          key: { query_id: 'foo' },
          at: Time.zone.local(2018, 10, 27),
          orders: 1,
          returning_orders: 0,
          customers: 1,
          units_sold: 2,
          merchandise: 10.to_m,
          discounts: 0.to_m,
          revenue: 10.to_m
        )

        Metrics::SearchByDay.inc(
          key: { query_id: 'foo' },
          at: Time.zone.local(2018, 10, 28),
          orders: 2,
          returning_orders: 1,
          customers: 2,
          units_sold: 4,
          merchandise: 20.to_m,
          discounts: -5.to_m,
          revenue: 15.to_m
        )

        Metrics::SearchByDay.inc(
          key: { query_id: 'bar' },
          at: Time.zone.local(2018, 10, 29),
          orders: 3,
          returning_orders: 1,
          customers: 2,
          units_sold: 6,
          merchandise: 30.to_m,
          discounts: -3.to_m,
          revenue: 27.to_m
        )
      end

      def time_travel
        travel_to Time.zone.local(2018, 10, 30)
      end

      def test_grouping_and_summing
        report = Searches.new
        assert_equal(4, report.results.length)

        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(6, foo['searches'])
        assert_equal(3, foo['total_results'])
        assert_equal(3, foo['orders'])
        assert_equal(6, foo['units_sold'])
        assert_equal(-5, foo['discounts'])
        assert_equal(25, foo['revenue'])

        bar = report.results.detect { |r| r['_id'] == 'bar' }
        assert_equal(9, bar['searches'])
        assert_equal(3, bar['total_results'])
        assert_equal(3, bar['orders'])
        assert_equal(6, bar['units_sold'])
        assert_equal(-3, bar['discounts'])
        assert_equal(27, bar['revenue'])

        baz = report.results.detect { |r| r['_id'] == 'baz' }
        assert_equal(3, baz['searches'])
        assert_equal(0, baz['total_results'])

        qux = report.results.detect { |r| r['_id'] == 'qux' }
        assert_equal(1, qux['searches'])
        assert_equal(0, qux['total_results'])
      end

      def test_date_ranges
        report = Searches.new
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(6, foo['searches'])
        assert_equal(3, foo['total_results'])
        assert_equal(3, foo['orders'])
        assert_equal(6, foo['units_sold'])
        assert_equal(-5, foo['discounts'])
        assert_equal(25, foo['revenue'])

        report = Searches.new(starts_at: '2018-10-28', ends_at: '2018-10-28')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(2, foo['searches'])
        assert_equal(2, foo['total_results'])
        assert_equal(2, foo['orders'])
        assert_equal(4, foo['units_sold'])
        assert_equal(-5, foo['discounts'])
        assert_equal(15, foo['revenue'])

        report = Searches.new(starts_at: '2018-10-28', ends_at: '2018-10-29')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(5, foo['searches'])
        assert_equal(3, foo['total_results'])
        assert_equal(2, foo['orders'])
        assert_equal(4, foo['units_sold'])
        assert_equal(-5, foo['discounts'])
        assert_equal(15, foo['revenue'])

        report = Searches.new(starts_at: '2018-10-28')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(5, foo['searches'])
        assert_equal(3, foo['total_results'])
        assert_equal(2, foo['orders'])
        assert_equal(4, foo['units_sold'])
        assert_equal(-5, foo['discounts'])
        assert_equal(15, foo['revenue'])

        report = Searches.new(ends_at: '2018-10-28')
        foo = report.results.detect { |r| r['_id'] == 'foo' }
        assert_equal(3, foo['searches'])
        assert_equal(2, foo['total_results'])
        assert_equal(3, foo['orders'])
        assert_equal(6, foo['units_sold'])
        assert_equal(-5, foo['discounts'])
        assert_equal(25, foo['revenue'])
      end

      def test_sorting
        report = Searches.new(sort_by: 'searches', sort_direction: 'asc')
        assert_equal('qux', report.results.first['_id'])

        report = Searches.new(sort_by: 'searches', sort_direction: 'desc')
        assert_equal('bar', report.results.first['_id'])
      end

      def test_filtering
        report = Searches.new(results_filter: nil)
        assert_equal(4, report.results.length)

        report = Searches.new(results_filter: 'with_results')
        assert_equal(2, report.results.length)
        assert_includes(report.results.map { |r| r['_id'] }, 'foo')
        assert_includes(report.results.map { |r| r['_id'] }, 'bar')

        report = Searches.new(results_filter: 'without_results')
        assert_equal(2, report.results.length)
        assert_includes(report.results.map { |r| r['_id'] }, 'baz')
        assert_includes(report.results.map { |r| r['_id'] }, 'qux')
      end
    end
  end
end
