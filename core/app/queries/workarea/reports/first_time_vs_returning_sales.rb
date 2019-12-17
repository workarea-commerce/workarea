module Workarea
  module Reports
    class FirstTimeVsReturningSales
      include Report
      include GroupByTime

      self.reporting_class = Metrics::SalesByDay
      self.sort_fields = %w(_id orders first_time_orders returning_orders percent_returning)

      def aggregation
        [filter, project_used_fields, group_by_time, add_calculated_fields]
      end

      def filter
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at.utc, '$lte' => ends_at.utc },
            'orders' => { '$gt' => 0 }
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            'reporting_on' => 1,
            'orders' => 1,
            'returning_orders' => 1
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
          }
        }
      end

      def add_calculated_fields
        {
          '$addFields' => {
            'first_time_orders' => { '$subtract' => ['$orders', '$returning_orders'] },
            'percent_returning' => {
              '$multiply' => [
                { '$divide' => ['$returning_orders', '$orders'] },
                100
              ]
            }
          }
        }
      end
    end
  end
end
