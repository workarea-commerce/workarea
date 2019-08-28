module Workarea
  module Admin
    class UnsubscribesController < Admin::ApplicationController
      skip_before_action :require_login
      skip_before_action :require_admin
      before_action :set_user

      def status_report
        if @user&.update(status_email_recipient: false)
          flash[:success] = t('workarea.admin.unsubscribe.flash_messages.status_report_success')
        else
          flash[:error] = t('workarea.admin.unsubscribe.flash_messages.status_report_error')
        end

        redirect_to storefront.root_url
      end

      def commentable
        commentable = GlobalID::Locator.locate(params[:commentable_id])

        if @user.present? && commentable&.remove_subscription(@user.id)
          flash[:success] = t(
            'workarea.admin.unsubscribe.flash_messages.commentable_success',
            commentable: commentable.name
          )
        else
          flash[:error] = t('workarea.admin.unsubscribe.flash_messages.commentable_error')
        end

        redirect_to storefront.root_url
      end

      private

      def set_user
        @user ||= User.find_by_token(params[:id])
      end
    end
  end
end
