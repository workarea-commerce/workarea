require 'test_helper'

module Workarea
  module Reports
    class CustomersTest < TestCase
      setup :add_data

      def add_data
        Metrics::User.save_order(
          email: 'returning-once@workarea.com',
          revenue: 10.to_m,
          at: Time.zone.local(2018, 11, 15)
        )

        Metrics::User.save_order(
          email: 'returning-once@workarea.com',
          revenue: 10.to_m,
          at: Time.zone.local(2018, 11, 16)
        )

        Metrics::User.save_order(
          email: 'returning-twice@workarea.com',
          revenue: 10.to_m,
          at: Time.zone.local(2018, 11, 14)
        )

        Metrics::User.save_order(
          email: 'returning-twice@workarea.com',
          revenue: 20.to_m,
          at: Time.zone.local(2018, 11, 15)
        )

        Metrics::User.save_order(
          email: 'returning-twice@workarea.com',
          revenue: 30.to_m,
          at: Time.zone.local(2018, 11, 16)
        )

        Metrics::User.save_order(
          email: 'once@workarea.com',
          revenue: 15.to_m,
          at: Time.zone.local(2018, 11, 15)
        )
      end

      def test_filtering
        report = Customers.new
        results = report.results.map { |r| r['_id'] }

        assert_equal(3, results.length)
        assert(results.include?('once@workarea.com'))
        assert(results.include?('returning-once@workarea.com'))
        assert(results.include?('returning-twice@workarea.com'))

        report = Customers.new(results_filter: 'returning')
        results = report.results.map { |r| r['_id'] }

        assert_equal(2, results.length)
        assert(results.include?('returning-once@workarea.com'))
        assert(results.include?('returning-twice@workarea.com'))

        report = Customers.new(results_filter: 'one_time')
        results = report.results.map { |r| r['_id'] }

        assert_equal(1, results.length)
        assert(results.include?('once@workarea.com'))
      end

      def test_projection
        report = Customers.new
        assert_equal(3, report.results.length)

        once = report.results.detect { |r| r['_id'] == 'once@workarea.com' }
        assert_equal(Time.zone.local(2018, 11, 15).to_i, once['first_order_at'].to_i)
        assert_equal(Time.zone.local(2018, 11, 15).to_i, once['last_order_at'].to_i)
        assert_equal(1, once['orders'])
        assert_equal(15, once['average_order_value'])
        assert_equal(15, once['revenue'])

        returning = report.results.detect { |r| r['_id'] == 'returning-once@workarea.com' }
        assert_equal(Time.zone.local(2018, 11, 15).to_i, returning['first_order_at'].to_i)
        assert_equal(Time.zone.local(2018, 11, 16).to_i, returning['last_order_at'].to_i)
        assert_equal(2, returning['orders'])
        assert_equal(10, returning['average_order_value'])
        assert_equal(20, returning['revenue'])

        twice = report.results.detect { |r| r['_id'] == 'returning-twice@workarea.com' }
        assert_equal(Time.zone.local(2018, 11, 14).to_i, twice['first_order_at'].to_i)
        assert_equal(Time.zone.local(2018, 11, 16).to_i, twice['last_order_at'].to_i)
        assert_equal(3, twice['orders'])
        assert_equal(20, twice['average_order_value'])
        assert_equal(60, twice['revenue'])
      end

      def test_sorting
        report = Customers.new(sort_by: 'orders', sort_direction: 'asc')
        assert_equal('once@workarea.com', report.results.first['_id'])

        report = Customers.new(sort_by: 'orders', sort_direction: 'desc')
        assert_equal('returning-twice@workarea.com', report.results.first['_id'])

        report = Customers.new(sort_by: 'average_order_value', sort_direction: 'asc')
        assert_equal('returning-once@workarea.com', report.results.first['_id'])

        report = Customers.new(sort_by: 'average_order_value', sort_direction: 'desc')
        assert_equal('returning-twice@workarea.com', report.results.first['_id'])
      end
    end
  end
end
