module Workarea
  module Storefront
    class ApplicationController < Workarea::ApplicationController
      include HttpCaching
      include Authentication
      include AdminGuestBrowsing
      include Impersonation
      include CurrentCheckout
      include CurrentRelease
      include UserActivity
      include OrderLookup
      include CurrentReferrer

      layout :current_layout

      helper :all
      helper_method :layout_content

      def health_check
        render plain: 'ok'
      end

      def current_user_info
        touch_auth_cookie
        render 'workarea/storefront/users/current_user'
      end

      def layout_content
        @layout_content ||= ContentViewModel.new(
          Content.for('layout'),
          view_model_options
        )
      end

      def current_layout
        if request.xhr? && params[:layout].to_s != 'true'
          false
        else
          'workarea/storefront/application'
        end
      end

      private

      def view_model_options
        super.merge(user: current_user)
      end
    end
  end
end
