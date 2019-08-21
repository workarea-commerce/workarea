module Workarea
  module Admin
    class BulkActionDeletionsController < Admin::ApplicationController
      before_action :find_bulk_action

      def edit
        confirm && (return) if @bulk_action.count < confirmation_threshold

        @search = BulkActionSelections.new(params[:id], params)
        @results = @search.results
                          .map { |r| wrap_in_view_model(r) }
                          .first(confirmation_threshold)
      end

      def confirm
        PublishBulkAction.perform_async(@bulk_action.id)

        flash[:success] =
          t('workarea.admin.bulk_action_deletions.flash_messages.created')
        redirect_to return_to.presence || root_path
      end

      private

      def find_bulk_action
        model = BulkAction::Deletion.find(params[:id])
        @bulk_action = Admin::BulkActionDeletionViewModel.new(
          model,
          view_model_options
        )
      end

      def confirmation_threshold
        Workarea.config.bulk_action_deletion_confirmation_threshold
      end
    end
  end
end
