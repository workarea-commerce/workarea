module Workarea
  module Admin
    module IntegrationTest
      extend ActiveSupport::Concern

      included do
        setup { set_current_user(admin_user) }
      end

      def admin_user
        @admin_user ||= create_user(super_admin: true)
      end
    end
  end
end
