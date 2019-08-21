module Workarea
  module Admin
    module UserParams
      def user_params
        result = params.fetch(:user, {}).deep_dup
        result[:avatar] = nil if params[:remove_avatar].present?

        if current_user.permissions_manager?
          result
        else
          result.except(:super_admin, *Workarea.config.permissions_fields)
        end
      end
    end
  end
end
