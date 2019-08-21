require 'test_helper'

module Workarea
  module Admin
    module Dashboards
      class InsightsGraphsTest < TestCase
        class ViewModel < ApplicationViewModel
          include InsightsGraphs
          add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :orders
        end

        def test_increasing
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 2), orders: 5)
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 9), orders: 15)
          travel_to Time.zone.local(2019, 1, 10)

          view_model = ViewModel.new
          assert_equal(15, view_model.orders)
          assert_equal(200, view_model.orders_percent_change)
          assert_equal(
            { Date.new(2019, 1, 3) => 0, Date.new(2019, 1, 9) => 15 },
            view_model.orders_graph_data
          )
        end

        def test_decreasing
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 2), orders: 25)
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 9), orders: 10)
          travel_to Time.zone.local(2019, 1, 10)

          view_model = ViewModel.new
          assert_equal(10, view_model.orders)
          assert_equal(-60, view_model.orders_percent_change)
          assert_equal(
            { Date.new(2019, 1, 3) => 0, Date.new(2019, 1, 9) => 10 },
            view_model.orders_graph_data
          )
        end

        def test_no_change
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 2), orders: 10)
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 9), orders: 10)
          travel_to Time.zone.local(2019, 1, 10)

          view_model = ViewModel.new
          assert_equal(10, view_model.orders)
          assert_equal(0, view_model.orders_percent_change)
          assert_equal(
            { Date.new(2019, 1, 3) => 0, Date.new(2019, 1, 9) => 10 },
            view_model.orders_graph_data
          )
        end

        def test_starting_with_nothing
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 2), orders: 0)
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 9), orders: 10)
          travel_to Time.zone.local(2019, 1, 10)

          view_model = ViewModel.new
          assert_equal(10, view_model.orders)
          assert_nil(view_model.orders_percent_change)
          assert_equal(
            { Date.new(2019, 1, 3) => 0, Date.new(2019, 1, 9) => 10 },
            view_model.orders_graph_data
          )
        end

        def test_time_frames
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 2), orders: 1)
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 3), orders: 2)
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 4), orders: 3)

          view_model = ViewModel.new(nil, starts_at: '2019-01-01', ends_at: '2019-01-05')
          assert_equal(6, view_model.orders)
          assert_equal(Time.zone.local(2019, 1, 1), view_model.starts_at)
          assert_equal(Time.zone.local(2019, 1, 5).end_of_day, view_model.ends_at)
          assert_equal(Time.zone.local(2018, 12, 26), view_model.previous_starts_at)
          assert_equal(Time.zone.local(2018, 12, 31).end_of_day, view_model.previous_ends_at)
          assert_nil(view_model.orders_percent_change)
          assert_equal(
            {
              Date.new(2019, 1, 1) => 0,
              Date.new(2019, 1, 2) => 1,
              Date.new(2019, 1, 3) => 2,
              Date.new(2019, 1, 4) => 3,
              Date.new(2019, 1, 5) => 0
            },
            view_model.orders_graph_data
          )

          view_model = ViewModel.new(nil, starts_at: '2019-01-03', ends_at: '2019-01-05')
          assert_equal(5, view_model.orders)
          assert_equal(Time.zone.local(2019, 1, 3), view_model.starts_at)
          assert_equal(Time.zone.local(2019, 1, 5).end_of_day, view_model.ends_at)
          assert_equal(Time.zone.local(2018, 12, 30), view_model.previous_starts_at)
          assert_equal(Time.zone.local(2019, 1, 2).end_of_day, view_model.previous_ends_at)
          assert_equal(400, view_model.orders_percent_change)
          assert_equal(
            { Date.new(2019, 1, 3) => 2, Date.new(2019, 1, 4) => 3, Date.new(2019, 1, 5) => 0 },
            view_model.orders_graph_data
          )
        end
      end
    end
  end
end
