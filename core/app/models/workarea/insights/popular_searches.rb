module Workarea
  module Insights
    class PopularSearches < Base
      class << self
        def dashboards
          %w(search)
        end

        def generate_monthly!
          results = generate_results
          create!(results: results) if results.present?
        end

        def generate_results
          report.results.take(Workarea.config.insights_searches_list_max_results)
        end

        def report
          Reports::Searches.new(
            starts_at: beginning_of_last_month,
            ends_at: end_of_last_month,
            sort_by: 'searches',
            sort_direction: 'desc'
          )
        end
      end
    end
  end
end
