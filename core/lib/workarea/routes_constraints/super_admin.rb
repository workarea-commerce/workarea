module Workarea
  module RoutesConstraints
    class SuperAdmin
      def matches?(request)
        user_id = request.cookie_jar.signed[:user_id]
        return false if user_id.blank?
        User.find(user_id).super_admin?
      end
    end
  end
end
