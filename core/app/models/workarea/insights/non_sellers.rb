module Workarea
  module Insights
    class NonSellers < Base
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
            .where(:orders.lt => 1, :views.gt => 0)
            .order_by(views: :desc, _id: :asc)
            .limit(Workarea.config.insights_products_list_max_results)
            .to_a
        end
      end
    end
  end
end
