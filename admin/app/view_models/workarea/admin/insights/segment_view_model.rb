module Workarea
  module Admin
    module Insights
      class SegmentViewModel < ApplicationViewModel
        include InsightsDetails

        insights_scope -> { Metrics::SegmentByDay.by_segment(model.id) }

        add_sparkline :orders
        add_summaries :orders, :revenue, :average_order_value
        add_graph_data :orders, :revenue, :average_order_value

        def average_order_value
          return nil if orders.zero?
          revenue / orders.to_f
        end

        def previous_average_order_value
          return nil if previous_orders.zero?
          previous_revenue / previous_orders.to_f
        end
      end
    end
  end
end
