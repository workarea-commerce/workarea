module Workarea
  class Storefront::RecentViewsController < Storefront::ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :block_robots

    def show
      if stale?(etag: user_activity, last_modified: user_activity.updated_at)
        @recent_views = Storefront::UserActivityViewModel.new(user_activity)
        render params[:view].in?(allowed_alt_views) ? params[:view] : :show
      end
    end

    def update
      if params[:product_id].present?
        Recommendation::UserActivity.save_product(
          current_user_activity_id,
          params[:product_id]
        )
      end

      if params[:category_id].present?
        Recommendation::UserActivity.save_category(
          current_user_activity_id,
          params[:category_id]
        )
      end

      if params[:search].present?
        Recommendation::UserActivity.save_search(
          current_user_activity_id,
          params[:search]
        )
      end

      head :ok
    end

    private

    def allowed_alt_views
      ['aside', 'narrow']
    end

    def block_robots
      if Robots.is_robot?(request.user_agent)
        head :forbidden
        return false
      end
    end
  end
end
