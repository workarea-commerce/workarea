module Workarea
  module Admin
    module Dashboards
      class PeopleViewModel < ApplicationViewModel
        include InsightsGraphs

        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :customers
        add_insights_graphs from: Workarea::Reports::FirstTimeVsReturningSales, on: :first_time_orders
        add_insights_graphs from: Workarea::Reports::FirstTimeVsReturningSales, on: :returning_orders

        def new_vs_returning_line_graph_data
          [
            {
              name: t('workarea.admin.dashboards.people.new'),
              data: first_time_orders_graph_data
            },
            {
              name: t('workarea.admin.dashboards.people.returning'),
              data: returning_orders_graph_data
            }
          ]
        end

        def new_vs_returning_pie_graph_data
          {
            t('workarea.admin.dashboards.people.new') => first_time_orders,
            t('workarea.admin.dashboards.people.returning') => returning_orders
          }
        end

        def insights
          @insights ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_dashboard('people').page(options[:page])
          )
        end
      end
    end
  end
end
