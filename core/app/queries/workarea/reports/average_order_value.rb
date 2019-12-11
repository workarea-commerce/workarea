module Workarea
  module Reports
    class AverageOrderValue
      include Report
      include GroupByTime

      self.reporting_class = Metrics::SalesByDay
      self.sort_fields = %w(_id revenue orders average_order_value)

      def aggregation
        [filter_date_range_and_zeroes, group_by_time, add_average_order_value]
      end

      def filter_date_range_and_zeroes
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at.utc, '$lte' => ends_at.utc },
            'orders' => { '$gt' => 0 },
            'revenue' => { '$gt' => 0 }
          }
        }
      end

      def group_by_time
        {
          '$group' => {
            '_id' => time_group_id,
            'starts_at' => { '$min' => '$reporting_on' },
            'orders' => { '$sum' => '$orders' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end

      def add_average_order_value
        {
          '$addFields' => {
            'average_order_value' => { '$divide' => ['$revenue', '$orders'] }
          }
        }
      end
    end
  end
end
