module Workarea
  module Insights
    class HotProducts < Base
      class << self
        def dashboards
          %w(catalog)
        end

        def generate_weekly!
          median = revenue_change_median
          standard_deviation = revenue_change_standard_deviation

          [2, 1, 0].each do |min_deviations|
            results = find_results(
              median: median,
              standard_deviation: standard_deviation,
              min_deviations: min_deviations
            )

            if results.present?
              create!(results: results.map(&:as_document))
              return
            end
          end
        end

        def find_results(median:, standard_deviation:, min_deviations:)
          min_revenue_change = median + (standard_deviation * min_deviations)
          min_revenue_change = min_revenue_change < 0 ? 0 : min_revenue_change

          Metrics::ProductByWeek
            .last_week
            .where(:revenue_change.gt => min_revenue_change)
            .order_by(revenue_change: :desc, prior_week_revenue: :desc, _id: :asc)
            .limit(Workarea.config.insights_products_list_max_results)
            .to_a
        end

        def revenue_change_median
          Metrics::ProductByWeek.last_week.improved_revenue.revenue_change_median
        end

        def revenue_change_standard_deviation
          Metrics::ProductByWeek.last_week.improved_revenue.revenue_change_standard_deviation
        end
      end
    end
  end
end
