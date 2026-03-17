# frozen_string_literal: true

module Workarea
  class Storefront::RecentViewsController < Storefront::ApplicationController
    skip_before_action :verify_authenticity_token

    def show
      if stale?(etag: current_metrics, last_modified: current_metrics.updated_at)
        @recent_views = Storefront::UserActivityViewModel.new(current_metrics, view_model_options)

        case params[:view].to_s
        when 'aside'
          render :aside
        when 'narrow'
          render :narrow
        else
          render :show
        end
      end
    end

  end
end
