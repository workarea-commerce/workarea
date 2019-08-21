module Workarea
  module Insights
    class MostDiscountGiven < Base
      class << self
        def dashboards
          %w(marketing)
        end

        def generate_monthly!
          results = generate_results
          create!(results: results) if results.present?
        end

        def generate_results
          total_discount = find_total_discount

          report
            .results
            .take(Workarea.config.insights_discounts_list_max_results)
            .map do |result|
              percent_of_total = if total_discount.zero?
                0
              else
                (result['discounts'] / total_discount.to_f) * 100
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
            sort_by: 'discounts',
            sort_direction: 'asc'
          )
        end

        def find_total_discount
          Metrics::DiscountByDay
            .where(:reporting_on.gte => beginning_of_last_month)
            .where(:reporting_on.lte => end_of_last_month)
            .sum(:discounts) || 0
        end
      end
    end
  end
end
