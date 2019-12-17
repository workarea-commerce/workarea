module Workarea
  module Reports
    class SalesByMenu
      include Report

      self.reporting_class = Metrics::MenuByDay
      self.sort_fields = %w(units_sold orders merchandise discounts tax revenue)

      def aggregation
        [filter, project_used_fields, group_by_menu]
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
            'menu_id' => 1,
            'orders' => 1,
            'units_sold' => 1,
            'merchandise' => 1,
            'discounts' => 1,
            'shipping' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_menu
        {
          '$group' => {
            '_id' => '$menu_id',
            'orders' => { '$sum' => '$orders' },
            'units_sold' => { '$sum' => '$units_sold' },
            'merchandise' => { '$sum' => '$merchandise' },
            'discounts' => { '$sum' => '$discounts' },
            'shipping' => { '$sum' => '$shipping' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end
    end
  end
end
