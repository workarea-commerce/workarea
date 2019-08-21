module Workarea
  module Insights
    class LowAovCustomers < Base
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
            .ordered_since(30.days.ago)
            .by_orders_percentile(81..100)
            .by_average_order_value_percentile(1..20)
            .order_by(orders: :desc, average_order_value: :desc, id: :asc)
            .limit(Workarea.config.insights_users_list_max_results)
            .to_a
        end
      end
    end
  end
end
