module Workarea
  module Insights
    class CustomersAtRisk < Base
      class << self
        def dashboards
          %w(people)
        end

        def generate_monthly!
          results = find_results
          create!(results: results.map(&:as_document)) if results.present?
        end

        def find_results
          Metrics::User
            .with_purchases
            .by_revenue_percentile(81..100)
            .where(:last_order_at.gte => 1.year.ago, :last_order_at.lt => 30.days.ago)
            .order_by(revenue: :desc, last_order_at: :asc, id: :asc)
            .limit(Workarea.config.insights_users_list_max_results)
            .to_a
        end
      end
    end
  end
end
