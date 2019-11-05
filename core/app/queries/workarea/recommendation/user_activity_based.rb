module Workarea
  module Recommendation
    class UserActivityBased
      def initialize(metrics)
        @metrics = metrics
      end

      def results
        if recent_product_ids.blank? && recent_category_ids.blank?
          popular_product_ids.take(max_results)
        else
          related_product_ids.take(max_results)
        end
      end

      def max_results
        # accommodate some missing or undisplayable products
        Workarea.config.per_page
      end

      def recent_product_ids
        @metrics.viewed.recent_product_ids(unique: true)
      end

      def recent_category_ids
        @metrics.viewed.recent_category_ids(unique: true)
      end

      def popular_product_ids
        Insights::TopProducts
          .current
          .results
          .map { |r| r['product_id'] }
          .take(max_results)
      end

      def related_product_ids
        query = Workarea::Search::RelatedProducts.new(
          product_ids: recent_product_ids,
          category_ids: recent_category_ids,
          exclude_product_ids: recent_product_ids
        )

        query.results.map { |r| r[:catalog_id] }
      end
    end
  end
end
