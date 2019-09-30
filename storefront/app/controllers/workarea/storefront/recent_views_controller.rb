module Workarea
  class Storefront::RecentViewsController < Storefront::ApplicationController
    skip_before_action :verify_authenticity_token

    def show
      if stale?(etag: current_metrics, last_modified: current_metrics.updated_at)
        @recent_views = Storefront::UserActivityViewModel.new(current_metrics, view_model_options)
        render params[:view].in?(allowed_alt_views) ? params[:view] : :show
      end
    end

    private

    def allowed_alt_views
      ['aside', 'narrow']
    end
  end
end
