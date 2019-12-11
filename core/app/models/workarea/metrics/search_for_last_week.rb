module Workarea
  module Metrics
    class SearchForLastWeek
      include Mongoid::Document
      include Mongoid::Attributes::Dynamic

      store_in client: :metrics

      index(searches: 1)
      index(query_id: 1)

      class << self
        def aggregate!
          delete_all
          aggregate_last_week
          add_searches_percentiles
        end

        def aggregate_last_week
          SearchByDay
            .collection
            .aggregate([
              filter_by_date_range,
              sort_by_most_usable_values,
              group_by_query,
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

        def sort_by_most_usable_values
          { '$sort' => { 'query_string' => -1, 'total_results' => -1 } }
        end

        def group_by_query
          {
            '$group' => {
              '_id' => '$query_id',
              'query_string' => { '$first' => '$query_string' },
              'total_results' => { '$first' => '$total_results' },
              'searches' => { '$sum' => '$searches' },
              'orders' => { '$sum' => '$orders' },
              'units_sold' => { '$sum' => '$units_sold' },
              'discounted_units_sold' => { '$sum' => '$discounted_units_sold' },
              'merchandise' => { '$sum' => '$merchandise' },
              'discounts' => { '$sum' => '$discounts' },
              'tax' => { '$sum' => '$tax' },
              'revenue' => { '$sum' => '$revenue' },
              'reporting_on' => { '$min' => '$reporting_on' }
            }
          }
        end

        def add_prior_week
          {
            '$lookup' => {
              'from' => SearchByWeek.collection.name,
              'let' => { 'query_id' => '$_id' },
              'pipeline' => [
                {
                  '$match' => {
                    '$expr' => {
                      '$and' => [
                        { '$eq' => ['$query_id', '$$query_id'] },
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
              'query_id' => '$_id',
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
                      { '$eq' => ['$searches', 0] },
                      0,
                      { '$divide' => ['$orders', '$searches'] }
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
                  '$query_id'
                ]
              }
            }
          }
        end

        def out
          { '$out' => collection.name }
        end

        def add_searches_percentiles
          percentiles = CalculatePercentiles.new(collection, :searches)

          collection.aggregate([
            {
              '$addFields' => {
                'searches_percentile' => {
                  '$switch' => {
                    'branches' => 99.downto(0).map do |percentile|
                      {
                        'case' => { '$gte' => ['$searches', percentiles[percentile.to_s]] },
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
