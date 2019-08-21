module Workarea
  class SaveOrderMetrics
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker
    include SaveMetrics

    sidekiq_options enqueue_on: { Order => :place }, queue: 'low'

    class << self
      def perform(order)
        return if order.metrics_saved?
        metrics = OrderMetrics.new(order)

        save_sales(metrics)
        save_user(metrics)
        save_catalog(metrics)
        save_traffic(metrics)
        save_pricing(metrics)
        save_tenders(metrics)
        save_segments(metrics)

        order.metrics_saved!
      end

      def save_user(metrics)
        Metrics::User.save_order(at: metrics.occured_at, **metrics.user_data)
        Metrics::User.save_affinity(
          id: metrics.email,
          action: 'purchased',
          product_ids: metrics.products.keys,
          category_ids: metrics.categories.keys,
          search_ids: metrics.searches.keys
        )
      end
    end

    def perform(order_id)
      self.class.perform(Order.find(order_id))
    end
  end
end
