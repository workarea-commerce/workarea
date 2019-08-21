module Workarea
  module Admin
    module Dashboards
      class SearchViewModel < ApplicationViewModel
        include InsightsGraphs

        add_insights_graphs from: Workarea::Reports::SearchesOverTime, on: :searches
        add_insights_graphs(
          from: Workarea::Reports::SearchesWithoutResultsOverTime,
          on: :searches,
          as: :searches_without_results
        )

        def insights
          @insights ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_dashboard('search').page(options[:page])
          )
        end
      end
    end
  end
end
