module Workarea
  module Admin
    module Insights
      class CategoryViewModel < ApplicationViewModel
        include InsightsDetails

        insights_scope -> { Metrics::CategoryByDay.by_category(model.id) }

        add_sparkline :orders
        add_summaries :views, :orders, :revenue, :units_sold
        add_graph_data :views, :orders, :revenue, :units_sold

        def feed
          @feed ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_category(model.id).to_a
          )
        end

        def top?
          Workarea::Insights::TopCategories.current.include?(category_id: model.id)
        end
      end
    end
  end
end
