module Workarea
  module AdminGuestBrowsing
    extend ActiveSupport::Concern
    include Authentication

    included do
      helper_method :admin_browsing_as_guest?
    end

    def admin_browse_as_guest
      session[:admin_id] = current_user.id
      touch_admin_guest_browsing
      logout
    end

    def admin_browsing_as_guest?
      session[:admin_id].present? && cookies.signed[:guest_browsing]
    end

    def stop_admin_guest_browsing
      cookies.signed[:user_id] = {
        value: current_admin.id,
        expires: Workarea.config.admin_session_timeout.from_now
      }

      session.delete(:admin_id)
      cookies.delete(:guest_browsing)
    end

    def touch_admin_guest_browsing
      cookies.signed[:guest_browsing] = {
        value: true,
        expires: Workarea.config.admin_session_timeout.from_now
      }
    end

    def current_admin
      @current_admin ||=
        if admin_browsing_as_guest?
          User.find(session[:admin_id])
        elsif current_user.try(:admin?)
          current_user
        end
    end

    def keep_auth_alive
      if admin_browsing_as_guest?
        touch_admin_guest_browsing
      else
        super
      end
    end
  end
end
