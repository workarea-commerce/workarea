module Workarea
  module Admin
    module BulkActionsHelper
      def bulk_actions_display_value_for(value)
        value.blank? ? '-' : value
      end
    end
  end
end
