module Workarea
  module Metrics
    module UpdateUserAggregations
      extend self

      def update!
        update_calculated_fields!
        update_percentiles!
      end

      def update_calculated_fields!
        User.collection.aggregate([
          {
            '$addFields' => {
              'frequency' => {
                '$cond' => [
                  { '$eq' => ['$orders', 0] },
                  nil,
                  {
                    '$divide' => [
                      '$orders',
                      { '$subtract' => [Time.current.utc, '$first_order_at'] }
                    ]
                  }
                ]
              },
              'average_order_value' => {
                '$cond' => [
                  { '$eq' => ['$orders', 0] },
                  nil,
                  { '$divide' => ['$revenue', '$orders'] }
                ]
              }
            }
          },
          { '$out' => User.collection.name }
        ]).first
      end

      def update_percentiles!
        User.collection.aggregate([
          {
            '$addFields' => {
              'orders_percentile' => update_percentiles_expression(:orders),
              'frequency_percentile' => update_percentiles_expression(:frequency),
              'revenue_percentile' => update_percentiles_expression(:revenue),
              'average_order_value_percentile' => update_percentiles_expression(:average_order_value)
            }
          },
          { '$out' => User.collection.name }
        ]).first
      end

      def update_percentiles_expression(field)
        percentiles = CalculatePercentiles.new(User.collection, field)

        {
          '$cond' => [
            { '$eq' => ['$orders', 0] },
            nil,
            {
              '$switch' => {
                'branches' => 99.downto(1).map do |percentile|
                  {
                    'case' => {  '$gte' => ["$#{field}", percentiles[percentile.to_s]] },
                    'then' => percentile + 1
                  }
                end,
                'default' => 1
              }
            }
          ]
        }
      end
    end
  end
end
