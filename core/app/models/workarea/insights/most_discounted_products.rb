module Workarea
  module Insights
    class MostDiscountedProducts < Base
      class << self
        def dashboards
          %w(catalog marketing)
        end

        def generate_weekly!
          results = generate_results
          create!(results: results.map(&:as_document)) if results.present?
        end

        def generate_results
          Metrics::ProductByWeek
            .last_week
            .where(:discount_rate.gt => 0, :orders.gt => 0)
            .order_by(average_discount: :desc, discount_rate: :desc, conversion_rate: :desc, _id: :asc)
            .limit(Workarea.config.insights_products_list_max_results)
            .to_a
        end
      end
    end
  end
end
