module Workarea
  class Storefront::Users::PasswordsController < Storefront::ApplicationController
    before_action :require_login, only: [:change, :make_change]
    skip_before_action :require_password_changes

    def new
    end

    def edit
      reset = User::PasswordReset.find_by(token: params[:token]) rescue nil

      unless reset
        flash[:error] = t('workarea.storefront.flash_messages.password_reset_expired')
        redirect_to forgot_password_path
      end
    end

    def create
      password_reset = User::PasswordReset.setup!(params[:email])
      if password_reset.present?
        Storefront::AccountMailer.password_reset(password_reset.id.to_s).deliver_later
      end

      flash[:success] = t(
        'workarea.storefront.flash_messages.password_reset_email_sent',
        email: params[:email]
      )
      redirect_to forgot_password_path
    end

    def update
      reset = User::PasswordReset.find_by(token: params[:token]) rescue nil

      if reset.blank?
        flash[:error] = t('workarea.storefront.flash_messages.password_reset_expired')
        render :edit
      elsif reset.complete(params[:password])
        flash[:success] = t('workarea.storefront.flash_messages.password_reset')
        redirect_to login_path
      else
        flash[:error] = reset.errors.full_messages.to_sentence
        redirect_to reset_password_path(token: reset.token)
      end
    end

    def change
    end

    def make_change
      unless current_user.authenticate(params[:old_password])
        flash[:error] = t('workarea.storefront.flash_messages.old_password_invalid')
        render :change and return
      end

      if params[:password].blank?
        flash[:error] = t('workarea.storefront.flash_messages.password_required')
        render :change and return
      end

      if current_user.update_attributes(password: params[:password])
        flash[:success] = t('workarea.storefront.flash_messages.password_reset')
        redirect_back_or users_account_path
      else
        flash[:error] = current_user.errors.full_messages
        render :change and return
      end
    end
  end
end
