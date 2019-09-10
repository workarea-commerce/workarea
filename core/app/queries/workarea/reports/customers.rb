module Workarea
  module Reports
    class Customers
      include Report

      self.reporting_class = Metrics::User
      self.sort_fields = %w(revenue refund first_order_at last_order_at orders average_order_value cancellations)

      def aggregation
        [filter_orders, add_returning, filter_returning, project_fields].compact
      end

      def filter_orders
        { '$match' => { 'orders' => { '$gt' => 0 } } }
      end

      def add_returning
        {
          '$addFields' => {
            'returning' => { '$ne' => ['$first_order_at', '$last_order_at'] }
          }
        }
      end

      def filter_returning
        if params[:results_filter] == 'returning'
          { '$match' => { 'returning' => true } }
        elsif params[:results_filter] == 'one_time'
          { '$match' => { 'returning' => false } }
        end
      end

      def project_fields
        {
          '$project' => {
            '_id' => 1,
            'first_order_at' => 1,
            'last_order_at' => 1,
            'orders' => 1,
            'cancellations' => 1,
            'revenue' => 1,
            'refund' => 1,
            'average_order_value' => { '$divide': ['$revenue', '$orders'] }
          }
        }
      end
    end
  end
end
