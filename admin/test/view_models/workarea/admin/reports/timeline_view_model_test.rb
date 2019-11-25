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

          create_release(
            name: 'Foo Release',
            published_at: Time.zone.local(2018, 1, 1)
          )

          Workarea::Reports::CustomEvent.create!(
            name: 'Foo Event',
            occurred_at: Time.zone.local(2018, 1, 2, 12)
          );

          Workarea::Reports::CustomEvent.create!(
            name: 'Bar Event',
            occurred_at: Time.zone.local(2018, 1, 2, 6)
          );

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
          assert_equal(2, view_model.summary[:custom_events])
        end

        def test_graph_data
          report = Workarea::Reports::SalesOverTime.new(
            starts_at: 2.days.ago,
            group_by: 'day'
          )

          view_model = TimelineViewModel.wrap(report)

          labels = view_model.graph_data[:labels]
          assert_equal(3, labels.size)

          assert_equal(Time.zone.local(2018, 1, 3).to_date, labels.first)
          assert_equal(Time.zone.local(2018, 1, 2).to_date, labels.second)
          assert_equal(Time.zone.local(2018, 1, 1).to_date, labels.third)

          datasets = view_model.graph_data[:datasets]
          assert_equal({ x: labels.third.to_time, y: 14.99 }, datasets[:revenue].third)
          assert_equal({ x: labels.second.to_time, y: 34.22 }, datasets[:revenue].second)
          assert_equal({ x: labels.third.to_time, y: 10 }, datasets[:orders].third)
          assert_equal({ x: labels.second.to_time, y: 5 }, datasets[:orders].second)
          assert_equal({ x: labels.third.to_time, y: 15 }, datasets[:units_sold].third)
          assert_equal({ x: labels.second.to_time, y: 9 }, datasets[:units_sold].second)
          assert_equal({ x: labels.third.to_time, y: 3 }, datasets[:customers].third)
          assert_equal({ x: labels.second.to_time, y: 13 }, datasets[:customers].second)
          assert_equal({ x: labels.third.to_time, y: 1 }, datasets[:releases].third)
          assert_equal({ x: labels.second.to_time, y: 0 }, datasets[:releases].second)
          assert_equal({ x: labels.second.to_time, y: 2 }, datasets[:custom_events].second)
        end

        def test_events
          report = Workarea::Reports::SalesOverTime.new(
            starts_at: 2.days.ago,
            group_by: 'day'
          )

          view_model = TimelineViewModel.wrap(report)

          assert_equal(1, view_model.events[Time.zone.local(2018, 1, 1).to_date].count)
          assert_equal(2, view_model.events[Time.zone.local(2018, 1, 2).to_date].count)

          assert_equal('Foo Release', view_model.events[Time.zone.local(2018, 1, 1).to_date].first.name)
          assert_equal('Bar Event', view_model.events[Time.zone.local(2018, 1, 2).to_date].first.name)
          assert_equal('Foo Event', view_model.events[Time.zone.local(2018, 1, 2).to_date].second.name)
        end
      end
    end
  end
end
