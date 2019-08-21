module Workarea
  class SaveOrderMetrics
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

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

        order.metrics_saved!
      end

      def save_sales(metrics)
        Metrics::SalesByDay.inc(at: metrics.placed_at, **metrics.sales_data)
      end

      def save_user(metrics)
        Metrics::User.save_order(
          email: metrics.email,
          revenue: metrics.total_price,
          discounts: metrics.sales_data[:discounts],
          at: metrics.placed_at
        )
      end

      def save_catalog(metrics)
        metrics.products.each do |product_id, data|
          Metrics::ProductByDay.inc(
            key: { product_id: product_id },
            at: metrics.placed_at,
            **data
          )
        end

        metrics.categories.each do |category_id, data|
          Metrics::CategoryByDay.inc(
            key: { category_id: category_id },
            at: metrics.placed_at,
            **data
          )
        end

        metrics.skus.each do |sku, data|
          Metrics::SkuByDay.inc(
            key: { sku: sku },
            at: metrics.placed_at,
            **data
          )
        end
      end

      def save_traffic(metrics)
        if metrics.country.present?
          Metrics::CountryByDay.inc(
            key: { country: metrics.country },
            at: metrics.placed_at,
            **metrics.sales_data
          )
        end

        metrics.searches.each do |query_id, data|
          Metrics::SearchByDay.inc(
            key: { query_id: query_id },
            at: metrics.placed_at,
            **metrics.sales_data
          )
        end

        if metrics.traffic_referrer.present?
          Metrics::TrafficReferrerByDay.inc(
            key: {
              medium: metrics.traffic_referrer.medium,
              source: metrics.traffic_referrer.source
            },
            at: metrics.placed_at,
            **metrics.sales_data
          )
        end
      end

      def save_pricing(metrics)
        metrics.discounts.each do |discount_id, data|
          Metrics::DiscountByDay.inc(
            key: { discount_id: discount_id },
            at: metrics.placed_at,
            **data
          )
        end
      end
    end

    def perform(order_id)
      self.class.perform(Order.find(order_id))
    end
  end
end
