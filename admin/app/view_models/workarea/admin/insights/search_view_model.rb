module Workarea
  module Admin
    module Insights
      class SearchViewModel < ApplicationViewModel
        include InsightsDetails

        insights_scope -> { Metrics::SearchByDay.by_query_id(model.id) }

        add_sparkline :orders
        add_summaries :orders, :searches, :revenue, :units_sold
        add_graph_data :orders, :searches, :revenue, :units_sold

        def feed
          @feed ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_search(model.id).to_a
          )
        end

        def top?
          Workarea::Insights::PopularSearches.current.include?(_id: model.id)
        end

        def trending?
          Workarea::Insights::TrendingSearches.current.include?(query_id: model.id)
        end
      end
    end
  end
end
