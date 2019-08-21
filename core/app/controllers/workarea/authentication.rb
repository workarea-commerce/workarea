module Workarea
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :current_user
      helper_method :logged_in?
      helper_method :return_to

      before_action :require_password_changes
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = User.find(cookies.signed[:user_id]) rescue nil
    end

    def login(user)
      @current_user = user
      user.update_login!(request)
      touch_auth_cookie
      user
    end

    def logout
      cookies.delete(:user_id)
      cookies.delete(:cache)
      cookies.delete(:completed_order)
      @current_user = nil
    end

    def touch_auth_cookie
      return if current_user.blank?

      cookies.signed[:user_id] = { value: current_user.id, expires: auth_expiry }

      if current_user.admin?
        cookies[:cache] = { value: 'false', expires: auth_expiry }
      end
    end
    alias_method :keep_auth_alive, :touch_auth_cookie

    def logged_in?
      current_user.present? && current_user.valid_logged_in_request?(request)
    end

    def require_login(should_remember_location = true)
      return if logged_in?

      flash[:info] = t('workarea.authentication.login')
      remember_location if request.get? && should_remember_location
      redirect_to storefront.login_path, turbolinks: false
      false
    end

    def require_logout
      if logged_in?
        flash[:info] = t('workarea.authentication.logout')
        redirect_to storefront.login_path
        return false
      end
    end

    def require_password_changes
      return unless logged_in?

      if current_user.force_password_change?
        flash[:warning] = t('workarea.authentication.password_expired')

        if request.xhr?
          head :unauthorized
        else
          redirect_to storefront.change_password_path
        end

        return false
      end
    end

    def remember_location(value = request.fullpath)
      url = URI.parse(return_to.presence || value).request_uri
      session[:return_to] = url[0..Workarea.config.return_to_url_max_length]
    end

    def return_to
      return nil unless params[:return_to].present?

      if params[:return_to].respond_to?(:to_h)
        url_for(params[:return_to].to_h.merge(only_path: true))
      else
        uri = URI.parse(params[:return_to])

        if uri.fragment.present?
          "#{uri.request_uri}##{uri.fragment}"
        else
          uri.request_uri
        end
      end
    end

    def redirect_back_or(default = root_path)
      remembered = return_to.presence || session[:return_to].presence
      session.delete(:return_to)
      redirect_to remembered || default
    end

    private

    def auth_expiry
      if current_user.admin?
        Workarea.config.admin_session_timeout.from_now
      else
        Workarea.config.customer_session_timeout.from_now
      end
    end
  end
end
