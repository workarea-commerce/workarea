module Workarea
  module Insights
    class SearchesToImprove < Base
      class << self
        def dashboards
          %w(search)
        end

        def generate_weekly!
          results = first_pass
          results = second_pass if results.blank?
          create!(results: results.map(&:as_document)) if results.present?
        end

        def first_pass
          Metrics::SearchByWeek
            .last_week
            .by_searches_percentile(91..100)
            .where(:conversion_rate.lt => avg_conversion_rate_of_top_two_searches_deciles)
            .order_by(conversion_rate: :asc, searches: :desc, _id: :asc)
            .limit(Workarea.config.insights_searches_list_max_results)
            .to_a
        end

        def avg_conversion_rate_of_top_two_searches_deciles
          Metrics::SearchByWeek.last_week.by_searches_percentile(81..100).avg(:conversion_rate)
        end

        def second_pass
          Metrics::SearchByWeek
            .last_week
            .where(:conversion_rate.lt => avg_conversion_rate_of_top_five_searches_deciles)
            .order_by(conversion_rate: :asc, searches: :desc, _id: :asc)
            .limit(Workarea.config.insights_searches_list_max_results)
            .to_a
        end

        def avg_conversion_rate_of_top_five_searches_deciles
          Metrics::SearchByWeek.last_week.by_searches_percentile(51..100).avg(:conversion_rate)
        end
      end
    end
  end
end
