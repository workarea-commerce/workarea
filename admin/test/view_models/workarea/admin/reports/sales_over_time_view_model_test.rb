require 'test_helper'

module Workarea
  module Admin
    module Reports
      class SalesOverTimeViewModelTest < TestCase
        def test_graph_data
          Metrics::SalesByDay.inc(at: Time.zone.local(2016, 1, 1), orders: 1, revenue: 15)
          Metrics::SalesByDay.inc(at: Time.zone.local(2017, 1, 1), orders: 1, revenue: 27)
          travel_to Time.zone.local(2018, 1, 1)

          report = Workarea::Reports::SalesOverTime.new(
            starts_at: 2.years.ago,
            group_by: 'year',
            sort_by: 'revenue',
            sort_direction: 'desc'
          )
          view_model = SalesOverTimeViewModel.wrap(report)

          assert_equal(2, view_model.graph_data.size)
          assert_equal([15], view_model.graph_data[Time.zone.local(2016, 1, 1)])
          assert_equal([27], view_model.graph_data[Time.zone.local(2017, 1, 1)])
        end
      end
    end
  end
end
