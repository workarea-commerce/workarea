require 'test_helper'

module Workarea
  module Admin
    module Dashboards
      class PeopleViewModelTest < TestCase
        def test_new_vs_returning
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 2), orders: 5, returning_orders: 1)
          Metrics::SalesByDay.inc(at: Time.zone.local(2019, 1, 9), orders: 15, returning_orders: 5)
          travel_to Time.zone.local(2019, 1, 10)

          view_model = PeopleViewModel.new
          assert_equal([10, 5], view_model.new_vs_returning_pie_graph_data.values)
          assert_equal(
            { Date.new(2019, 1, 3) => 0, Date.new(2019, 1, 9) => 10 },
            view_model.new_vs_returning_line_graph_data.first[:data]
          )
          assert_equal(
            { Date.new(2019, 1, 3) => 0, Date.new(2019, 1, 9) => 5 },
            view_model.new_vs_returning_line_graph_data.second[:data]
          )
        end
      end
    end
  end
end
