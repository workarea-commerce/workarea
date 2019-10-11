module Workarea
  module Authorization
    extend ActiveSupport::Concern

    module ClassMethods
      def required_permissions(*values)
        values = @required_permissions if values.blank?
        @required_permissions ||= values || []
      end

      def reset_permissions!
        @required_permissions = nil
      end
    end

    def require_admin
      unless current_user.try(:admin?)
        flash[:error] = t('workarea.admin.authorization.unauthorized_action')
        redirect_to storefront.root_path
        return false
      end
    end

    def required_permissions
      self.class.required_permissions
    end

    def check_authorization
      return if current_user.blank? || current_user.super_admin?
      return if required_permissions.blank?

      unauthorized_user and return false unless authorized?
    end

    def authorized?
      current_user.admin? && Array(required_permissions).all? do |area|
        current_user.try("#{area}_access?") || current_user.try("#{area}?")
      end
    end

    def unauthorized_user
      flash[:error] = t('workarea.admin.authorization.unauthorized_area')
      redirect_back fallback_location: root_path
    end
  end
end
