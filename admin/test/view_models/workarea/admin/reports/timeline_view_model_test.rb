require 'test_helper'

module Workarea
  module Admin
    module Reports
      class TimelineViewModelTest < TestCase
        setup :create_metrics

        def create_metrics
          Metrics::SalesByDay.inc(
            at: Time.zone.local(2018, 1, 1),
            revenue: 14.99,
            orders: 10,
            units_sold: 15,
            customers: 3
          )

          Metrics::SalesByDay.inc(
            at: Time.zone.local(2018, 1, 2),
            revenue: 34.22,
            orders: 5,
            units_sold: 9,
            customers: 13
          )

          create_release(published_at: Time.zone.local(2018, 1, 1))

          travel_to Time.zone.local(2018, 1, 3)
        end

        def test_summary_data
          report = Workarea::Reports::SalesOverTime.new(
            starts_at: 2.days.ago,
            group_by: 'day'
          )

          view_model = TimelineViewModel.wrap(report)

          assert_equal(14.99 + 34.22, view_model.summary[:revenue])
          assert_equal(15, view_model.summary[:orders])
          assert_equal(24, view_model.summary[:units_sold])
          assert_equal(16, view_model.summary[:customers])
          assert_equal(1, view_model.summary[:releases])
        end

        def test_graph_data
          report = Workarea::Reports::SalesOverTime.new(
            starts_at: 2.days.ago,
            group_by: 'day'
          )

          view_model = TimelineViewModel.wrap(report)

          labels = view_model.graph_data[:labels]
          assert_equal(2, labels.size)
          assert_equal(2.days.ago, labels.first)
          assert_equal(1.day.ago, labels.second)

          datasets = view_model.graph_data[:datasets]
          assert_equal({ x: labels.first, y: 14.99 }, datasets[:revenue].first)
          assert_equal({ x: labels.second, y: 34.22 }, datasets[:revenue].second)
          assert_equal({ x: labels.first, y: 10 }, datasets[:orders].first)
          assert_equal({ x: labels.second, y: 5 }, datasets[:orders].second)
          assert_equal({ x: labels.first, y: 15 }, datasets[:units_sold].first)
          assert_equal({ x: labels.second, y: 9 }, datasets[:units_sold].second)
          assert_equal({ x: labels.first, y: 3 }, datasets[:customers].first)
          assert_equal({ x: labels.second, y: 13 }, datasets[:customers].second)
          assert_equal({ x: labels.first, y: 1 }, datasets[:releases].first)
          assert_equal({ x: labels.second, y: 0 }, datasets[:releases].second)
        end
      end
    end
  end
end
