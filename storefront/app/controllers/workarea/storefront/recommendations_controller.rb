module Workarea
  class Storefront::RecommendationsController < Storefront::ApplicationController
    def show
      fresh_when(etag: user_activity, last_modified: user_activity.updated_at)
      @recommendations = Storefront::PersonalizedRecommendationsViewModel.new(
        user_activity,
        view_model_options
      )
    end
  end
end
