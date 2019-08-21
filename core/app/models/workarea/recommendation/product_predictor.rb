module Workarea
  module Recommendation
    class ProductPredictor
      include Predictor::Base

      limit_similarities_to Workarea.config.max_recommendation_similarities
      input_matrix :orders, measure: :sorensen_coefficient
    end
  end
end
