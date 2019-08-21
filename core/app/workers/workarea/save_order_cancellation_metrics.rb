module Workarea
  class SaveOrderCancellationMetrics
    include Sidekiq::Worker
    include SaveMetrics

    class << self
      def perform(order, cancel_data = {})
        metrics = OrderCancellationMetrics.new(
          order,
          **cancel_data.symbolize_keys
        )

        save_sales(metrics)
        save_user(metrics)
        save_products(metrics)
        save_skus(metrics)
        save_country(metrics)
        save_segments(metrics)

        order.metrics_saved!
      end

      def save_user(metrics)
        Metrics::User.save_cancellation(
          at: metrics.occured_at,
          **metrics.user_data
        )
      end
    end

    def perform(order_id, cancel_data = {})
      self.class.perform(Order.find(order_id), cancel_data)
    end
  end
end
