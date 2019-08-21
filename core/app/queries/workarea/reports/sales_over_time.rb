module Workarea
  module Reports
    class SalesOverTime
      include Report
      include GroupByTime

      self.reporting_class = Metrics::SalesByDay
      self.sort_fields = %w(_id units_sold orders customers merchandise discounts shipping tax revenue)

      def aggregation
        [filter, project_used_fields, group_by_time, add_aov]
      end

      def filter
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at, '$lte' => ends_at },
            'orders' => { '$gt' => 0 }
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            'reporting_on' => 1,
            'orders' => 1,
            'returning_orders' => 1,
            'customers' => 1,
            'units_sold' => 1,
            'merchandise' => 1,
            'shipping' => 1,
            'discounts' => 1,
            'tax' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_time
        {
          '$group' => {
            '_id' => time_group_id,
            'starts_at' => { '$min' => '$reporting_on' },
            'orders' => { '$sum' => '$orders' },
            'returning_orders' => { '$sum' => '$returning_orders' },
            'customers' => { '$sum' => '$customers' },
            'units_sold' => { '$sum' => '$units_sold' },
            'merchandise' => { '$sum' => '$merchandise' },
            'shipping' => { '$sum' => '$shipping' },
            'discounts' => { '$sum' => '$discounts' },
            'tax' => { '$sum' => '$tax' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end

      def add_aov
        {
          '$addFields' => {
            'aov' => {
              '$cond' => [
                { '$eq' => ['$orders', 0] },
                0,
                { '$divide' => ['$revenue', '$orders'] }
              ]
            }
          }
        }
      end
    end
  end
end
