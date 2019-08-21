module Workarea
  module Storefront
    class DetailPageRecommendationsViewModel < RecommendationsViewModel
      def product_ids
        Recommendation::ProductBased.new(model).results
      end

      def result_count
        Workarea.config.detail_page_recommendations_count
      end
    end
  end
end
