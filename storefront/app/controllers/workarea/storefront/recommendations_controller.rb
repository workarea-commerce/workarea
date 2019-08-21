module Workarea
  class Storefront::RecommendationsController < Storefront::ApplicationController
    def show
      fresh_when(etag: current_metrics, last_modified: current_metrics.updated_at)
      @recommendations = Storefront::PersonalizedRecommendationsViewModel.new(
        current_metrics,
        view_model_options
      )
    end
  end
end
