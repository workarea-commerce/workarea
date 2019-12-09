module Workarea
  module Reports
    class Searches
      include Report

      self.reporting_class = Metrics::SearchByDay
      self.sort_fields = %w(searches query_string total_results orders units_sold discounts revenue)

      def aggregation
        [filter_date_range, project_used_fields, group_by_query_id]
      end

      def filter_date_range
        {
          '$match' => {
            'reporting_on' => { '$gte' => starts_at.utc, '$lte' => ends_at.utc },
            'total_results' => total_results_query
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            'query_id' => 1,
            'query_string' => 1,
            'total_results' => 1,
            'searches' => 1,
            'orders' => 1,
            'units_sold' => 1,
            'discounts' => 1,
            'revenue' => 1
          }
        }
      end

      def group_by_query_id
        {
          '$group' => {
            '_id' => '$query_id',
            'query_string' => { '$first' => '$query_string' },
            'total_results' => { '$last' => '$total_results' },
            'searches' => { '$sum' => '$searches' },
            'orders' => { '$sum' => '$orders' },
            'units_sold' => { '$sum' => '$units_sold' },
            'discounts' => { '$sum' => '$discounts' },
            'revenue' => { '$sum' => '$revenue' }
          }
        }
      end

      private

      def total_results_query
        if params[:results_filter] == 'without_results'
          { '$eq' => 0 }
        elsif params[:results_filter] == 'with_results'
          { '$gt' => 0 }
        else
          { '$gte' => 0 }
        end
      end
    end
  end
end
