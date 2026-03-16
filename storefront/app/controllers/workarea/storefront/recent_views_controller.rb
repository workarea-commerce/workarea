# frozen_string_literal: true

module Workarea
  class Storefront::RecentViewsController < Storefront::ApplicationController
    ALLOWED_VIEWS = %w[show aside narrow].freeze

    skip_before_action :verify_authenticity_token

    def show
      if stale?(etag: current_metrics, last_modified: current_metrics.updated_at)
        @recent_views = Storefront::UserActivityViewModel.new(current_metrics, view_model_options)
        view = ALLOWED_VIEWS.include?(params[:view].to_s) ? params[:view].to_s : 'show'
        render view
      end
    end

    private

    def allowed_alt_views
      ALLOWED_VIEWS
    end
  end
end
