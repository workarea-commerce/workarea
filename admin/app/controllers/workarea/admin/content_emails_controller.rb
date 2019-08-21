module Workarea
  class Admin::ContentEmailsController < Admin::ApplicationController
    required_permissions :marketing
    before_action :find_email, except: :index

    def index
      @emails = Content::Email.all
    end

    def edit; end

    def update
      if @email.update_attributes(email_params)
        flash[:success]= t(
          'workarea.admin.content_emails.flash_messages.updated',
          type: @email.type.titleize
        )
        redirect_to content_emails_path
      else
        render :edit
      end
    end

    private

    def find_email
      @email = Content::Email.find(params[:id])
    end

    def email_params
      return {} unless params[:email].present?
      params[:email].permit(:content)
    end
  end
end
