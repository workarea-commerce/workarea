module Workarea
  class Storefront::EmailSignupsController < Storefront::ApplicationController
    def show
      @content = Storefront::EmailSignupsViewModel.new
    end

    def create
      signup = Email.signup(params[:email])

      if signup.try(:valid?)
        flash[:success] = t('workarea.storefront.flash_messages.email_signed_up')
      else
        flash[:error] = t('workarea.storefront.flash_messages.email_signup_error')
      end

      redirect_back fallback_location: root_path
    end
  end
end
