module Workarea
  module Admin
    module Dashboards
      class IndexViewModel < ApplicationViewModel
        include InsightsGraphs

        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :orders
        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :revenue
        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :customers
        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :units_sold

        def today
          @today ||= Workarea::Metrics::SalesByDay.today
        end

        def yesterday
          @yesterday ||= Workarea::Metrics::SalesByDay.yesterday
        end

        def insights
          @insights ||= InsightViewModel.wrap(
            Workarea::Insights::Base.all.page(options[:page])
          )
        end
      end
    end
  end
end
