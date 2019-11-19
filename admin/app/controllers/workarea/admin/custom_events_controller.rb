module Workarea
  module Admin
    class CustomEventsController < Admin::ApplicationController
      before_action :find_event

      def create
        flash[:success] = t('workarea.admin.reports.timeline.flash_messages.created')
        redirect_back fallback_location: root_path
      end

      def update
        if @custom_event.update_attributes(params[:custom_event])
          flash[:success] =
            t('workarea.admin.reports.timeline.flash_messages.success')
        else
          flash[:error] =
            t('workarea.admin.reports.timeline.flash_messages.error')
        end

        redirect_back fallback_location: root_path
      end

      def destroy
        @custom_event.destroy
        flash[:success] = t('workarea.admin.reports.timeline.flash_messages.success')
        redirect_back fallback_location: root_path
      end

      private

      def find_event
        @custom_event = if params[:id].present?
          Workarea::Reports::CustomEvent.find_by(id: params[:id])
        else
          Workarea::Reports::CustomEvent.create!(params[:custom_event])
        end
      end
    end
  end
end
