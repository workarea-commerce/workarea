module Workarea
  module Insights
    class StarSearches < Base
      class << self
        def dashboards
          %w(search)
        end

        def generate_weekly!
          results = generate_results
          create!(results: results.map(&:as_document)) if results.present?
        end

        def generate_results
          Metrics::SearchByWeek
            .last_week
            .by_searches_percentile(91..100)
            .where(:conversion_rate.gt => avg_conversion_rate_of_top_two_searches_deciles)
            .order_by(conversion_rate: :desc, searches: :desc, _id: :asc)
            .limit(Workarea.config.insights_searches_list_max_results)
            .to_a
        end

        def avg_conversion_rate_of_top_two_searches_deciles
          Metrics::SearchByWeek.last_week.by_searches_percentile(81..100).avg(:conversion_rate)
        end
      end
    end
  end
end
