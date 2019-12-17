module Workarea
  module Reports
    class SalesBySku
      include Report

      self.reporting_class = Metrics::SkuByDay
      self.sort_fields = %w(units_sold units_canceled orders merchandise discounts tax refund revenue _id average_price)

      def skus
        Array.wrap(params[:skus])
      end

      def aggregation
        [filter, project_used_fields, group_by_sku, add_average_price]
      end

      def filter
        result = {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at.utc, '$lte' => ends_at.utc },
            '$or' => [
              { 'orders' => { '$gt' => 0 } },
              { 'units_sold' => { '$gt' => 0 } },
              { 'units_canceled' => { '$gt' => 0 } }
            ]
          }
        }

        result['$match']['sku'] = { '$in' => skus } if skus.present?
        result
      end

      def project_used_fields
        {
          '$project' => {
            'sku' => 1,
            'orders' => 1,
            'units_sold' => 1,
            'units_canceled' => 1,
            'merchandise' => 1,
            'discounts' => 1,
            'tax' => 1,
            'refund' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_sku
        {
          '$group' => {
            '_id' => '$sku',
            'orders' => { '$sum' => '$orders' },
            'units_sold' => { '$sum' => '$units_sold' },
            'units_canceled' => { '$sum' => '$units_canceled' },
            'merchandise' => { '$sum' => '$merchandise' },
            'discounts' => { '$sum' => '$discounts' },
            'tax' => { '$sum' => '$tax' },
            'refund' => { '$sum' => '$refund' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end

      def add_average_price
        {
          '$addFields' => {
            'average_price' => {
              '$cond' => {
                'if' => { '$lt' => ['$units_sold', 1] },
                'then' => 0,
                'else' => {
                  '$divide' => [
                    {
                      '$trunc' => {
                        '$multiply' => [
                          { '$divide' => [
                              { '$sum' => ['$merchandise', '$discounts'] },
                              '$units_sold'
                            ]
                          },
                          100
                        ]
                      }
                    },
                    100
                  ]
                }
              }
            }
          }
        }
      end
    end
  end
end
