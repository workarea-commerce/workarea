module Workarea
  module Storefront
    module UserActivity
      def user_activity
        return Recommendation::UserActivity.new if current_user_activity_id.blank?

        @user_activity ||= Recommendation::UserActivity.find_or_initialize_by(
          id: current_user_activity_id
        )
      end

      def current_user_activity_id
        current_user.try(:id).presence || session.id
      end
    end
  end
end
