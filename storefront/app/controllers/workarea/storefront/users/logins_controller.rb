module Workarea
  class Storefront::Users::LoginsController < Storefront::ApplicationController
    before_action :ensure_not_locked, only: :create
    skip_before_action :require_password_changes, only: :destroy

    def new
      @user = User.new
    end

    def create
      if user = User.find_for_login(params[:email], params[:password])
        login(user)

        login_service = Login.new(user, current_order).tap(&:perform)
        self.current_order = login_service.current_order

        flash[:success] = t('workarea.storefront.flash_messages.logged_in')
        redirect_back_or users_dashboard_path
      else
        flash[:error] = t('workarea.storefront.flash_messages.login_failure')
        @user = User.new
        render 'new', status: 422
      end
    end

    def destroy
      logout
      clear_current_order
      flash[:success] = t('workarea.storefront.flash_messages.logged_out')
      redirect_to login_path
    end

    private

    def users_dashboard_path
      current_user.admin? ? admin.root_path : users_account_path
    end

    def ensure_not_locked
      if User.login_locked?(params[:email])
        flash[:error] = t('workarea.storefront.flash_messages.account_locked')
        redirect_to(login_path)
        return false
      end
    end
  end
end
