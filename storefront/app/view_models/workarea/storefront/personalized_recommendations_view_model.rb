module Workarea
  module Storefront
    class PersonalizedRecommendationsViewModel < RecommendationsViewModel
      def product_ids
        Recommendation::UserActivityBased.new(model).results
      end

      def result_count
        Workarea.config.personalized_recommendations_count
      end
    end
  end
end
