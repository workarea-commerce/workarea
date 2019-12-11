module Workarea
  module Reports
    class SalesByTrafficReferrer
      include Report

      self.reporting_class = Metrics::TrafficReferrerByDay
      self.sort_fields = %w(
        units_sold
        orders
        merchandise
        discounts
        shipping
        tax
        revenue
        _id.medium
        _id.source
      )

      def aggregation
        [filter, project_used_fields, group_by_traffic_referrer]
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
            'medium' => 1,
            'source' => 1,
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

      def group_by_traffic_referrer
        {
          '$group' => {
            '_id' => { 'medium' => '$medium', 'source' => '$source' },
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
