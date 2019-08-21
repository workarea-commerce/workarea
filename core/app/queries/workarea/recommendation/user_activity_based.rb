module Workarea
  module Recommendation
    class UserActivityBased
      def initialize(user_activity)
        @user_activity = user_activity
      end

      def results
        if @user_activity.product_ids.blank? && @user_activity.category_ids.blank?
          popular_product_ids.take(max_results)
        else
          related_product_ids.take(max_results)
        end
      end

      def max_results
        # accommodate some missing or undisplayable products
        Workarea.config.per_page
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
          product_ids: @user_activity.product_ids,
          category_ids: @user_activity.category_ids,
          exclude_product_ids: @user_activity.product_ids
        )

        query.results.map { |r| r[:catalog_id] }
      end
    end
  end
end
