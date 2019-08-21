module Workarea
  module Reports
    class SalesBySku
      include Report

      self.reporting_class = Metrics::SkuByDay
      self.sort_fields = %w(units_sold orders merchandise discounts tax revenue _id)

      def skus
        Array.wrap(params[:skus])
      end

      def aggregation
        [filter, project_used_fields, group_by_sku]
      end

      def filter
        result = {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at, '$lte' => ends_at },
            '$or' => [
              { 'orders' => { '$gt' => 0 } },
              { 'units_sold' => { '$gt' => 0 } }
            ]
          }
        }

        result['$match']['sku'] = { '$in' => skus } if skus.present?
        result
      end

      def project_used_fields
        {
          '$project' => {
            'sku' => 1,
            'orders' => 1,
            'units_sold' => 1,
            'merchandise' => 1,
            'discounts' => 1,
            'tax' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_sku
        {
          '$group' => {
            '_id' => '$sku',
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
