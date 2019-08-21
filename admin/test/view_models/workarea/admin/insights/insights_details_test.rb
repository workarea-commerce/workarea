require 'test_helper'

module Workarea
  module Admin
    module Insights
      class InsightsDetailsTest < TestCase
        class TestViewModel < ApplicationViewModel
          include InsightsDetails
          insights_scope -> { Metrics::ProductByDay.by_product('foo') }

          add_sparkline :orders
          add_summaries :orders
          add_graph_data :orders
        end

        setup :add_data

        def add_data
          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 26),
            orders: 10
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 27),
            orders: 10
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 28),
            orders: 15
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 29),
            orders: 27
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'bar' },
            at: Time.zone.local(2018, 10, 27),
            orders: 11
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'bar' },
            at: Time.zone.local(2018, 10, 28),
            orders: 15
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'bar' },
            at: Time.zone.local(2018, 10, 29),
            orders: 27
          )
        end

        def test_date_ranges
          view_model = TestViewModel.wrap('foo', starts_at: '2019-01-21', ends_at: '2019-01-21')
          assert_equal(Time.zone.local(2019, 1, 20), view_model.previous_starts_at)
          assert_equal(Time.zone.local(2019, 1, 20).end_of_day, view_model.previous_ends_at)

          view_model = TestViewModel.wrap('foo', starts_at: '2019-01-20', ends_at: '2019-01-21')
          assert_equal(Time.zone.local(2019, 1, 18), view_model.previous_starts_at)
          assert_equal(Time.zone.local(2019, 1, 19).end_of_day, view_model.previous_ends_at)

          view_model = TestViewModel.wrap('foo', starts_at: '2019-01-01', ends_at: '2019-01-31')
          assert_equal(Time.zone.local(2018, 12, 1), view_model.previous_starts_at)
          assert_equal(Time.zone.local(2018, 12, 31).end_of_day, view_model.previous_ends_at)
        end

        def test_current_period
          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-24', ends_at: '2018-10-25')
          assert_equal(0, view_model.current_period.size)

          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-27', ends_at: '2018-10-28')
          assert_equal(2, view_model.current_period.size)
          assert(view_model.current_period.all? { |p| p.product_id == 'foo' })
          assert_equal(
            [Time.zone.local(2018, 10, 27), Time.zone.local(2018, 10, 28)],
            view_model.current_period.map(&:reporting_on)
          )

          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-26', ends_at: '2018-10-28')
          assert_equal(3, view_model.current_period.size)
          assert(view_model.current_period.all? { |p| p.product_id == 'foo' })
          assert_equal(
            [Time.zone.local(2018, 10, 26), Time.zone.local(2018, 10, 27), Time.zone.local(2018, 10, 28)],
            view_model.current_period.map(&:reporting_on)
          )

          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-26', ends_at: '2018-10-29')
          assert_equal(4, view_model.current_period.size)
          assert(view_model.current_period.all? { |p| p.product_id == 'foo' })
          assert_equal(
            [
              Time.zone.local(2018, 10, 26),
              Time.zone.local(2018, 10, 27),
              Time.zone.local(2018, 10, 28),
              Time.zone.local(2018, 10, 29)
            ],
            view_model.current_period.map(&:reporting_on)
          )
        end

        def test_previous_period
          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-24', ends_at: '2018-10-25')
          assert_equal(0, view_model.previous_period.size)

          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-27', ends_at: '2018-10-28')
          assert_equal(1, view_model.previous_period.size)
          assert(view_model.previous_period.all? { |p| p.product_id == 'foo' })
          assert_equal(Time.zone.local(2018, 10, 26), view_model.previous_period.first.reporting_on)

          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-28', ends_at: '2018-10-29')
          assert_equal(2, view_model.previous_period.size)
          assert(view_model.previous_period.all? { |p| p.product_id == 'foo' })
          assert_equal(
            [Time.zone.local(2018, 10, 26), Time.zone.local(2018, 10, 27)],
            view_model.previous_period.map(&:reporting_on)
          )
        end

        def test_aggregate_methods
          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-27', ends_at: '2018-10-28')
          assert_equal(25, view_model.orders)
          assert_equal(10, view_model.previous_orders)
          assert_equal(150, view_model.orders_percent_change)
        end

        def test_sparklines
          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-26', ends_at: '2018-10-28')
          assert_equal([10, 10, 15], view_model.orders_sparkline)

          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-27', ends_at: '2018-10-28')
          assert_equal([10, 15], view_model.orders_sparkline)
        end

        def test_graph_data
          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-26', ends_at: '2018-10-28')
          assert_equal(
            { Date.new(2018, 10, 26) => 10, Date.new(2018, 10, 27) => 10, Date.new(2018, 10, 28) => 15 },
            view_model.orders_graph_data
          )

          view_model = TestViewModel.wrap('foo', starts_at: '2018-10-27', ends_at: '2018-10-28')
          assert_equal(
            { Date.new(2018, 10, 27) => 10, Date.new(2018, 10, 28) => 15 },
            view_model.orders_graph_data
          )
        end
      end
    end
  end
end
