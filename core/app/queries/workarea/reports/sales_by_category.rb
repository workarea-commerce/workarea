module Workarea
  module Reports
    class SalesByCategory
      include Report

      self.reporting_class = Metrics::CategoryByDay
      self.sort_fields = %w(units_sold orders merchandise discounts tax revenue)

      def aggregation
        [filter, project_used_fields, group_by_category]
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
            'category_id' => 1,
            'orders' => 1,
            'units_sold' => 1,
            'merchandise' => 1,
            'discounts' => 1,
            'tax' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_category
        {
          '$group' => {
            '_id' => '$category_id',
            'orders' => { '$sum' => '$orders' },
            'units_sold' => { '$sum' => '$units_sold' },
            'merchandise' => { '$sum' => '$merchandise' },
            'discounts' => { '$sum' => '$discounts' },
            'tax' => { '$sum' => '$tax' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end
    end
  end
end
