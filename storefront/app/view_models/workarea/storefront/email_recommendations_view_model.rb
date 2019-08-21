module Workarea
  module Storefront
    class EmailRecommendationsViewModel < RecommendationsViewModel
      def product_ids
        Recommendation::OrderBased.new(model).results
      end

      def result_count
        Workarea.config.email_recommendations_count
      end
    end
  end
end
