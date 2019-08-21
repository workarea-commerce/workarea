module Workarea
  module Admin
    class EmailSignupsController < Admin::ApplicationController
      def index
        @email_signups = Email::Signup
                          .all
                          .order_by(created_at: :desc)
                          .page(params[:page])
      end

      def destroy
        signup = Email::Signup.find(params[:id])
        signup.destroy

        flash[:success] = t('workarea.admin.email_signups.flash_messages.destroyed')
        redirect_to email_signups_path
      end
    end
  end
end
