module Workarea
  module Admin
    class BulkActionProductEditsController < Admin::ApplicationController
      required_permissions :catalog
      before_action :find_bulk_action

      def edit
      end

      def update
        @bulk_action.reset_to_default!

        if @bulk_action.update_attributes(params[:bulk_action])
          flash[:success] =
            t('workarea.admin.bulk_action_product_edits.flash_messages.success')
          redirect_to review_bulk_action_product_edit_path(@bulk_action)
        else
          flash[:error] =
            t('workarea.admin.bulk_action_product_edits.flash_messages.error')
          render :edit
        end
      end

      def review
      end

      def publish
        release = SavePublishing.new(nil, params).release

        if release.nil? || release.valid?
          @bulk_action.update_attributes(release_id: release.try(:id))
          PublishBulkAction.perform_async(@bulk_action.id)

          flash[:success] =
            t('workarea.admin.bulk_action_product_edits.flash_messages.publish')

          redirect_to catalog_products_path
        else
          flash[:error] = release.errors.full_messages
          render :review
        end
      end

      private

      def find_bulk_action
        model = BulkAction::ProductEdit.find(params[:id])
        @bulk_action = Admin::BulkActionProductEditViewModel.new(
          model,
          view_model_options
        )
      end
    end
  end
end
