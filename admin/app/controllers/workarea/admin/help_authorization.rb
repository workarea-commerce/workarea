module Workarea
  module Admin
    module HelpAuthorization
      extend ActiveSupport::Concern

      included do
        before_action :check_help_authorization
      end

      private

      def check_help_authorization
        unauthorized_user and return false unless current_user.help_admin?
      end
    end
  end
end
