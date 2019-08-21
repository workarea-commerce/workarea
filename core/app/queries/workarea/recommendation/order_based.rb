module Workarea
  module Recommendation
    class OrderBased
      def initialize(order)
        @order = order
      end

      def results
        @results ||=
          begin
            result = prediction_product_ids
            return result if result.size == max_results
            (result + related_product_ids).uniq.take(max_results)
          end
      end

      def related_product_ids
        query = Workarea::Search::RelatedProducts.new(
          product_ids: order_product_ids,
          category_ids: order_category_ids,
          exclude_product_ids: order_product_ids
        )

        query.results.map { |r| r[:catalog_id] }.first(max_results)
      end

      def prediction_product_ids
        ProductPredictor.new.predictions_for(
          item_set: order_product_ids,
          limit: max_results
        )
      end

      def order_product_ids
        @order.items.map(&:product_id)
      end

      def order_category_ids
        @order.items.map(&:category_ids).flatten
      end

      def max_results
        # accommodate some missing or undisplayable products
        Workarea.config.per_page
      end
    end
  end
end
