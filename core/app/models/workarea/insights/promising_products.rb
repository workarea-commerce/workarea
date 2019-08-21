module Workarea
  module Insights
    class PromisingProducts < Base
      class << self
        def dashboards
          %w(catalog)
        end

        def generate_weekly!
          results = first_pass
          results = second_pass if results.blank?
          create!(results: results.map(&:as_document)) if results.present?
        end

        def first_pass
          Metrics::ProductByWeek
            .last_week
            .by_views_percentile(1..70)
            .where(:views.gt => 20)
            .where(:conversion_rate.gt => avg_conversion_rate_of_bottom_seven_views_deciles)
            .order_by(conversion_rate: :desc, views: :desc, _id: :asc)
            .limit(Workarea.config.insights_products_list_max_results)
            .to_a
        end

        def avg_conversion_rate_of_bottom_seven_views_deciles
          Metrics::ProductByWeek.last_week.by_views_percentile(1..70).avg(:conversion_rate)
        end

        def second_pass
          Metrics::ProductByWeek
            .last_week
            .by_views_percentile(1..70)
            .where(:views.gte => avg_views_of_bottom_seven_views_deciles)
            .where(:conversion_rate.gt => avg_conversion_rate_of_bottom_seven_views_deciles)
            .order_by(conversion_rate: :desc, views: :desc, _id: :asc)
            .limit(Workarea.config.insights_products_list_max_results)
            .to_a
        end

        def avg_views_of_bottom_seven_views_deciles
          Metrics::ProductByWeek.last_week.by_views_percentile(1..70).avg(:views)
        end
      end
    end
  end
end
