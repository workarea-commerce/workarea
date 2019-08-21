module Workarea
  module Reports
    class SalesByCountry
      include Report

      self.reporting_class = Metrics::CountryByDay
      self.sort_fields = %w(orders units_sold merchandise discounts shipping tax revenue)

      def aggregation
        [filter, project_used_fields, group_by_country]
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
            'country' => 1,
            'orders' => 1,
            'units_sold' => 1,
            'merchandise' => 1,
            'shipping' => 1,
            'discounts' => 1,
            'tax' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_country
        {
          '$group' => {
            '_id' => '$country',
            'orders' => { '$sum' => '$orders' },
            'units_sold' => { '$sum' => '$units_sold' },
            'merchandise' => { '$sum' => '$merchandise' },
            'shipping' => { '$sum' => '$shipping' },
            'discounts' => { '$sum' => '$discounts' },
            'tax' => { '$sum' => '$tax' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end
    end
  end
end
