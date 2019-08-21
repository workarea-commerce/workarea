module Workarea
  module Impersonation
    extend ActiveSupport::Concern
    include Authorization
    include AdminGuestBrowsing

    included do
      helper_method :impersonating?
      helper_method :current_admin
      helper_method :current_impersonation

      prepend_before_action :check_impersonation_status
    end

    def impersonate_user(user)
      session[:admin_id] = current_user.id

      cookies.signed[:user_id] = {
        value: user.id,
        expires: Workarea.config.customer_session_timeout.from_now
      }

      user.mark_impersonated_by!(current_user)
      @current_user = user
    end

    def stop_impersonation
      cookies.signed[:user_id] = {
        value: current_admin.id,
        expires: Workarea.config.admin_session_timeout.from_now
      }

      session.delete(:admin_id)
    end

    def impersonating?(user = nil)
      session[:admin_id].present? &&
        cookies.signed[:user_id].present? &&
        session[:admin_id] != cookies.signed[:user_id] &&
        (user.blank? || user.id.to_s == cookies.signed[:user_id])
    end

    def current_admin
      @current_admin ||=
        if impersonating? || admin_browsing_as_guest?
          User.find(session[:admin_id])
        elsif current_user.try(:admin?)
          current_user
        end
    end

    def current_impersonation
      @current_impersonation ||= User.find(cookies.signed[:user_id])
    end

    def touch_impersonation
      cookies.signed[:user_id] = {
        value: cookies.signed[:user_id],
        expires: Workarea.config.customer_session_timeout.from_now
      }
    end

    def keep_auth_alive
      if impersonating?
        touch_impersonation
      else
        super
      end
    end

    #
    # Override when impersonating to prevent IP address and user agent
    # validation.
    #
    def logged_in?
      if impersonating?
        current_user.present?
      else
        super
      end
    end

    private

    def check_impersonation_status
      if !(impersonating? || admin_browsing_as_guest?) && session[:admin_id].present?
        session.delete(:admin_id)
        session.delete(:order_id)
      end
    end
  end
end
