module Workarea
  module Reports
    class SalesByCountry
      include Report

      self.reporting_class = Metrics::CountryByDay
      self.sort_fields = %w(orders cancellations units_sold units_canceled merchandise discounts shipping tax refund revenue)

      def aggregation
        [filter, project_used_fields, group_by_country]
      end

      def filter
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at.utc, '$lte' => ends_at.utc },
            '$or' => [
              { 'orders' => { '$gt' => 0 } },
              { 'units_sold' => { '$gt' => 0 } },
              { 'units_canceled' => { '$gt' => 0 } }
            ]
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            'country' => 1,
            'orders' => 1,
            'cancellations' => 1,
            'units_sold' => 1,
            'units_canceled' => 1,
            'merchandise' => 1,
            'shipping' => 1,
            'discounts' => 1,
            'tax' => 1,
            'refund' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_country
        {
          '$group' => {
            '_id' => '$country',
            'orders' => { '$sum' => '$orders' },
            'cancellations' => { '$sum' => '$cancellations' },
            'units_sold' => { '$sum' => '$units_sold' },
            'units_canceled' => { '$sum' => '$units_canceled' },
            'merchandise' => { '$sum' => '$merchandise' },
            'shipping' => { '$sum' => '$shipping' },
            'discounts' => { '$sum' => '$discounts' },
            'tax' => { '$sum' => '$tax' },
            'refund' => { '$sum' => '$refund' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end
    end
  end
end
