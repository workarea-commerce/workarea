module Workarea
  module Insights
    class TopDiscounts < Base
      class << self
        def dashboards
          %w(marketing)
        end

        def generate_monthly!
          results = generate_results
          create!(results: results) if results.present?
        end

        def generate_results
          total_orders = find_total_orders

          report
            .results
            .take(Workarea.config.insights_discounts_list_max_results)
            .map do |result|
              percent_of_total = if total_orders.zero?
                0
              else
                (result['orders'] / total_orders.to_f) * 100
              end

              result.merge(
                discount_id: result['_id'],
                percent_of_total: percent_of_total
              )
            end
        end

        def report
          Reports::SalesByDiscount.new(
            starts_at: beginning_of_last_month,
            ends_at: end_of_last_month,
            sort_by: 'revenue',
            sort_direction: 'desc'
          )
        end

        def find_total_orders
          Metrics::SalesByDay
            .by_date_range(starts_at: beginning_of_last_month, ends_at: end_of_last_month)
            .sum(:orders) || 0
        end
      end
    end
  end
end
