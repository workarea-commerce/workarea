module Workarea
  module Reports
    class Customers
      include Report

      self.reporting_class = Metrics::User
      self.sort_fields = %w(revenue first_order_at last_order_at orders average_order_value)

      def aggregation
        result = [add_returning]
        result << filter_to_returning if params[:results_filter] == 'returning'
        result << filter_to_one_time if params[:results_filter] == 'one_time'
        result + [project_fields]
      end

      def add_returning
        {
          '$addFields' => {
            'returning' => { '$ne' => ['$first_order_at', '$last_order_at'] }
          }
        }
      end

      def filter_to_returning
        { '$match' => { 'returning' => true } }
      end

      def filter_to_one_time
        { '$match' => { 'returning' => false } }
      end

      def project_fields
        {
          '$project' => {
            '_id' => 1,
            'first_order_at' => 1,
            'last_order_at' => 1,
            'orders' => 1,
            'revenue' => 1,
            'average_order_value' => { '$divide': ['$revenue', '$orders'] }
          }
        }
      end
    end
  end
end
