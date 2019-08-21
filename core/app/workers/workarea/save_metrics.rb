module Workarea
  module SaveMetrics
    extend ActiveSupport::Concern

    class_methods do
      def save_sales(metrics)
        Metrics::SalesByDay.inc(at: metrics.occured_at, **metrics.sales_data)
      end

      def save_catalog(metrics)
        save_products(metrics)
        save_categories(metrics)
        save_skus(metrics)
      end

      def save_products(metrics)
        metrics.products.each do |product_id, data|
          Metrics::ProductByDay.inc(
            key: { product_id: product_id },
            at: metrics.occured_at,
            **data
          )
        end
      end

      def save_categories(metrics)
        metrics.categories.each do |category_id, data|
          Metrics::CategoryByDay.inc(
            key: { category_id: category_id },
            at: metrics.occured_at,
            **data
          )
        end
      end

      def save_skus(metrics)
        metrics.skus.each do |sku, data|
          Metrics::SkuByDay.inc(
            key: { sku: sku },
            at: metrics.occured_at,
            **data
          )
        end
      end

      def save_traffic(metrics)
        save_country(metrics)
        save_searches(metrics)
        save_traffic_referrer(metrics)
      end

      def save_country(metrics)
        if metrics.country.present?
          Metrics::CountryByDay.inc(
            key: { country: metrics.country },
            at: metrics.occured_at,
            **metrics.sales_data
          )
        end
      end

      def save_searches(metrics)
        metrics.searches.each do |query_id, data|
          Metrics::SearchByDay.inc(
            key: { query_id: query_id },
            at: metrics.occured_at,
            **metrics.sales_data
          )
        end
      end

      def save_traffic_referrer(metrics)
        if metrics.traffic_referrer.present?
          Metrics::TrafficReferrerByDay.inc(
            key: {
              medium: metrics.traffic_referrer.medium,
              source: metrics.traffic_referrer.source
            },
            at: metrics.occured_at,
            **metrics.sales_data
          )
        end
      end

      def save_pricing(metrics)
        metrics.discounts.each do |discount_id, data|
          Metrics::DiscountByDay.inc(
            key: { discount_id: discount_id },
            at: metrics.occured_at,
            **data
          )
        end
      end

      def save_tenders(metrics)
        metrics.tenders.each do |tender, data|
          Metrics::TenderByDay.inc(
            key: { tender: tender },
            at: metrics.occured_at,
            **data
          )
        end
      end

      def save_segments(metrics)
        metrics.segments.each do |segment_id, data|
          Metrics::SegmentByDay.inc(
            key: { segment_id: segment_id },
            at: metrics.occured_at,
            **data
          )
        end
      end
    end
  end
end
