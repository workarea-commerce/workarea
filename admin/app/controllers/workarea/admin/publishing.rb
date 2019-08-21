module Workarea
  module Admin
    module Publishing
      extend ActiveSupport::Concern

      included do
        around_action :set_publishing_options
        helper_method :allow_publishing?
      end

      def allow_publishing?
        @allow_publishing ||= current_user && current_user.can_publish_now?
      end

      def allow_publishing!
        @allow_publishing = true
      end

      def set_publishing_options
        return yield if request.get? || params[:publishing].blank?

        release = Release.find(params[:publishing]) rescue nil
        self.current_release = release if current_release != release
        yield

      ensure
        Release.current = nil
      end

      private

      def check_publishing_authorization
        return if current_user.blank?
        return if request.get? || current_release.present?

        unauthorized_publish && (return false) unless allow_publishing?
      end

      def unauthorized_publish
        flash[:error] = t('workarea.admin.publish_authorization.unauthorized')
        redirect_back fallback_location: root_path
      end
    end
  end
end
