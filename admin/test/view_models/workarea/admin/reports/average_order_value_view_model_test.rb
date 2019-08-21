require 'test_helper'

module Workarea
  module Admin
    module Reports
      class AverageOrderValueViewModelTest < TestCase
        def test_graph_data
          Metrics::SalesByDay.inc(at: Time.zone.local(2016, 1, 1), orders: 2, revenue: 10)
          Metrics::SalesByDay.inc(at: Time.zone.local(2017, 1, 1), orders: 3, revenue: 9)

          travel_to Time.zone.local(2018, 1, 1)
          report = Workarea::Reports::AverageOrderValue.new(
            starts_at: 2.years.ago,
            group_by: 'year',
            sort_by: 'orders',
            sort_direction: 'asc'
          )
          view_model = AverageOrderValueViewModel.wrap(report)

          assert_equal(2, view_model.graph_data.size)
          assert_equal([5], view_model.graph_data[Time.zone.local(2016, 1, 1)])
          assert_equal([3], view_model.graph_data[Time.zone.local(2017, 1, 1)])
        end
      end
    end
  end
end
