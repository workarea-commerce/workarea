module Workarea
  module Metrics
    class ProductForLastWeek
      include Mongoid::Document
      include Mongoid::Attributes::Dynamic

      store_in client: :metrics

      index(views: 1)
      index(product_id: 1)

      class << self
        def aggregate!
          delete_all
          aggregate_last_week
          add_view_percentiles
        end

        def aggregate_last_week
          ProductByDay
            .collection
            .aggregate([
              filter_by_date_range,
              group_by_product,
              add_prior_week,
              merge_prior_week_data,
              add_calculated_fields,
              add_id,
              out
            ])
            .first
        end

        def filter_by_date_range
          {
            '$match' => {
              'reporting_on' => {
                '$gte' => Time.current.last_week.utc,
                '$lte' => Time.current.last_week.end_of_week.utc
              }
            }
          }
        end

        def group_by_product
          {
            '$group' => {
              '_id' => '$product_id',
              'views' => { '$sum' => '$views' },
              'orders' => { '$sum' => '$orders' },
              'units_sold' => { '$sum' => '$units_sold' },
              'discounted_units_sold' => { '$sum' => '$discounted_units_sold' },
              'merchandise' => { '$sum' => '$merchandise' },
              'discounts' => { '$sum' => '$discounts' },
              'tax' => { '$sum' => '$tax' },
              'revenue' => { '$sum' => '$revenue' },
              'reporting_on' => { '$min' => '$reporting_on' },
              'units_canceled' => { '$sum' => '$units_canceled' },
              'refund' => { '$sum' => '$refund' }
            }
          }
        end

        def add_prior_week
          {
            '$lookup' => {
              'from' => ProductByWeek.collection.name,
              'let' => { 'product_id' => '$_id' },
              'pipeline' => [
                {
                  '$match' => {
                    '$expr' => {
                      '$and' => [
                        { '$eq' => ['$product_id', '$$product_id'] },
                        { '$gte' => ['$reporting_on', (Time.current.last_week - 1.week).utc] },
                        { '$lte' => ['$reporting_on', (Time.current.last_week.end_of_week - 1.week).utc] }
                      ]
                    }
                  }
                },
                { '$project' => { 'prior_week_revenue' => '$revenue' } }
              ],
              'as' => 'prior_week'
            }
          }
        end

        def merge_prior_week_data
          {
            '$replaceRoot' => {
              'newRoot' => {
                '$mergeObjects' => [
                  { '$arrayElemAt' => ['$prior_week', 0] },
                  '$$ROOT'
                ]
              }
            }
          }
        end

        def add_calculated_fields
          {
            '$addFields' => {
              'product_id' => '$_id',
              'prior_week_revenue' => { '$ifNull' => ['$prior_week_revenue', 0] },
              'revenue_change' => {
                '$subtract' => ['$revenue', '$ifNull' => ['$prior_week_revenue', 0]]
              },
              'average_discount' => {
                '$cond' => [
                  { '$eq' => ['$merchandise', 0] },
                  0,
                  { '$divide' => [{ '$abs' => '$discounts' }, '$merchandise'] }
                ]
              },
              'discount_rate' => {
                '$multiply' => [
                  100,
                  {
                    '$cond' => [
                      { '$eq' => ['$units_sold', 0] },
                      0,
                      { '$divide' => ['$discounted_units_sold', '$units_sold'] }
                    ]
                  }
                ]
              },
              'conversion_rate' => {
                '$multiply' => [
                  100,
                  {
                    '$cond' => [
                      { '$eq' => ['$views', 0] },
                      0,
                      { '$divide' => ['$orders', '$views'] }
                    ]
                  }
                ]
              }
            }
          }
        end

        def add_id
          {
            '$addFields' => {
              '_id' => {
                '$concat' => [
                  {
                    '$dateToString' => {
                      'format' => '%Y%m%d',
                      'date' => '$reporting_on',
                      'timezone' => Time.zone.tzinfo.name
                    }
                  },
                  '-',
                  '$product_id'
                ]
              }
            }
          }
        end

        def out
          { '$out' => collection.name }
        end

        def add_view_percentiles
          percentiles = CalculatePercentiles.new(collection, :views)

          collection.aggregate([
            {
              '$addFields' => {
                'views_percentile' => {
                  '$switch' => {
                    'branches' => 99.downto(0).map do |percentile|
                      {
                        'case' => { '$gte' => ['$views', percentiles[percentile.to_s]] },
                        'then' => percentile + 1
                      }
                    end,
                    'default' => 0
                  }
                }
              }
            },
            out
          ]).first
        end
      end
    end
  end
end
