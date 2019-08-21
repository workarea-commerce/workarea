module Workarea
  module Recommendation
    class SearchPredictor
      include Predictor::Base

      limit_similarities_to Workarea.config.max_recommendation_similarities
      input_matrix :sessions, measure: :sorensen_coefficient
    end
  end
end
