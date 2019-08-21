module Workarea
  module Reports
    class SalesByProduct
      include Report

      self.reporting_class = Metrics::ProductByDay
      self.sort_fields = %w(units_sold orders merchandise discounts tax revenue)

      def aggregation
        [filter, project_used_fields, group_by_product]
      end

      def filter
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at, '$lte' => ends_at },
            '$or' => [
              { 'orders' => { '$gt' => 0 } },
              { 'units_sold' => { '$gt' => 0 } }
            ]
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            'product_id' => 1,
            'orders' => 1,
            'units_sold' => 1,
            'merchandise' => 1,
            'discounts' => 1,
            'tax' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_product
        {
          '$group' => {
            '_id' => '$product_id',
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
