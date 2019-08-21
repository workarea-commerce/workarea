module Workarea
  module Admin
    class BulkActionDeletionViewModel < ApplicationViewModel
      def resource_name
        if model_type.present?
          model_type.constantize.model_name.param_key.titleize
        else
          t('workarea.admin.bulk_action_deletions.generic_name')
        end
      end
    end
  end
end
