module Workarea
  module Insights
    class StarProducts < Base
      class << self
        def dashboards
          %w(catalog)
        end

        def generate_weekly!
          results = generate_results
          create!(results: results.map(&:as_document)) if results.present?
        end

        def generate_results
          Metrics::ProductByWeek
            .last_week
            .by_views_percentile(91..100)
            .where(:conversion_rate.gt => avg_conversion_rate_of_top_two_views_deciles)
            .order_by(conversion_rate: :desc, views: :desc, _id: :asc)
            .limit(Workarea.config.insights_products_list_max_results)
            .to_a
        end

        def avg_conversion_rate_of_top_two_views_deciles
          Metrics::ProductByWeek.last_week.by_views_percentile(81..100).avg(:conversion_rate)
        end
      end
    end
  end
end
