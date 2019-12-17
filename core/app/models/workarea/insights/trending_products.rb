module Workarea
  module Insights
    class TrendingProducts < Base
      class << self
        def dashboards
          %w(catalog)
        end

        def generate_monthly!
          results = generate_results.map { |r| r.merge(product_id: r['_id']) }
          create!(results: results) if results.present?
        end

        def generate_results
          Metrics::ProductByWeek
            .collection
            .aggregate([filter_date_range, group_by_product, add_improving_weeks, sort, limit])
            .to_a
        end

        def filter_date_range
          {
            '$match' => {
              'reporting_on' => {
                '$gte' => beginning_of_last_month.utc,
                '$lte' => end_of_last_month.utc
              }
            }
          }
        end

        def group_by_product
          {
            '$group' => {
              '_id' => '$product_id',
              'improving_weeks' => { '$sum' => 1 },
              'revenue_changes' => { '$push' => '$revenue_change' },
              'orders' => { '$sum' => '$orders' }
            }
          }
        end

        def add_improving_weeks
          {
            '$addFields' => {
              'improving_weeks' => {
                '$size' => {
                  '$filter' => {
                    'input' => '$revenue_changes',
                    'as' => 'revenue_change',
                    'cond' => { '$gt' => ['$$revenue_change', 0] }
                  }
                }
              }
            }
          }
        end

        def sort
          { '$sort' => { 'improving_weeks' => -1, 'orders' => -1 } }
        end

        def limit
          { '$limit' => Workarea.config.insights_products_list_max_results }
        end
      end
    end
  end
end
