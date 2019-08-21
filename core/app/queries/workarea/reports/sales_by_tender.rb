module Workarea
  module Reports
    class SalesByTender
      include Report

      self.reporting_class = Metrics::TenderByDay
      self.sort_fields = %w(orders revenue)

      def aggregation
        [filter_date_range, project_used_fields, group_by_country]
      end

      def filter_date_range
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at, '$lte' => ends_at }
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            'tender' => 1,
            'orders' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_country
        {
          '$group' => {
            '_id' => '$tender',
            'orders' => { '$sum' => '$orders' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end
    end
  end
end
