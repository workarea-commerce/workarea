module Workarea
  module Admin
    module Dashboards
      class OrdersViewModel < ApplicationViewModel
        include InsightsGraphs

        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :orders
        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :revenue
        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :aov
        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :units_sold

        def insights
          @insights ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_dashboard('orders').page(options[:page])
          )
        end
      end
    end
  end
end
