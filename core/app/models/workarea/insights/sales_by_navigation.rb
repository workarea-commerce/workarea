module Workarea
  module Insights
    class SalesByNavigation < Base
      class << self
        def dashboards
          %w(store)
        end

        def generate_monthly!
          results = generate_results
          create!(results: results) if results.present?
        end

        def generate_results
          total_revenue = find_total_revenue

          report
            .results
            .map do |result|
              percent_of_total = if total_revenue.zero?
                0
              else
                (result['revenue'] / total_revenue.to_f) * 100
              end

              result.merge(
                menu_id: result['_id'],
                percent_of_total: percent_of_total
              )
            end
        end

        def report
          Reports::SalesByMenu.new(
            starts_at: beginning_of_last_month,
            ends_at: end_of_last_month,
            sort_by: 'revenue',
            sort_direction: 'desc'
          )
        end

        def find_total_revenue
          Metrics::SalesByDay
            .by_date_range(starts_at: beginning_of_last_month, ends_at: end_of_last_month)
            .sum(:revenue) || 0
        end
      end
    end
  end
end
