module Workarea
  module Reports
    class SalesByDiscount
      include Report

      self.reporting_class = Metrics::DiscountByDay
      self.sort_fields = %w(discounts orders merchandise revenue)

      def aggregation
        [filter, project_used_fields, group_by_discount]
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
            'discount_id' => 1,
            'orders' => 1,
            'merchandise' => 1,
            'discounts' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_discount
        {
          '$group' => {
            '_id' => '$discount_id',
            'orders' => { '$sum' => '$orders' },
            'merchandise' => { '$sum' => '$merchandise' },
            'discounts' => { '$sum' => '$discounts' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end
    end
  end
end
