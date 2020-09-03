module Workarea
  module Impersonation
    extend ActiveSupport::Concern
    include Authorization

    included do
      helper_method :impersonating?
      helper_method :admin_browsing_as_guest?
      helper_method :current_admin
      helper_method :current_impersonation
    end

    def impersonate_user(user)
      session[:admin_id] = current_user.id.to_s
      session[:user_id] = user.id.to_s

      user.mark_impersonated_by!(current_user)
      update_tracking!(email: user.email)
    end

    def stop_impersonation
      update_tracking!(email: current_admin.email)
      session[:user_id] = current_admin.id.to_s
      session.delete(:admin_id)
    end

    def impersonating?(user = nil)
      session[:admin_id].present? &&
        session[:admin_id] != session[:user_id] &&
        (user.blank? || user.id.to_s == session[:user_id])
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
      return @current_impersonation if defined?(@current_impersonation)
      @current_impersonation = User.find(session[:user_id]) rescue nil
    end

    def admin_browse_as_guest
      session[:admin_id] = current_user.id.to_s
      session.delete(:user_id)
    end

    def admin_browsing_as_guest?
      session[:admin_id].present? && session[:user_id].blank?
    end

    def stop_admin_guest_browsing
      session[:user_id] = current_admin.id.to_s
      session.delete(:admin_id)
    end

    #
    # Override when impersonating to prevent IP address and user agent
    # validation.
    #
    def logged_in?
      super || (impersonating? && !admin_browsing_as_guest? && current_admin.present?)
    end
  end
end
