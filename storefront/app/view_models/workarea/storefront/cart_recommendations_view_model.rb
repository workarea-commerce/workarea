module Workarea
  module Storefront
    class CartRecommendationsViewModel < RecommendationsViewModel
      def product_ids
        Recommendation::OrderBased.new(model).results
      end

      def result_count
        Workarea.config.cart_recommendations_count
      end
    end
  end
end
