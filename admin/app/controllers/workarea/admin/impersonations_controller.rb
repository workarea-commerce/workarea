module Workarea
  module Admin
    class InvalidImpersonation < StandardError; end

    class ImpersonationsController < Admin::ApplicationController
      include Storefront::CurrentCheckout
      required_permissions :people

      def create
        new_user = User.find(params[:user_id])
        raise InvalidImpersonation if new_user.admin?

        impersonate_user(new_user)
        login = Login.new(new_user, Order.new)
        self.current_order = login.previous_order || Order.new

        flash[:success] = t(
          'workarea.admin.users.flash_messages.started',
          email: new_user.email
        )
        redirect_to storefront.users_account_path
      end

      def destroy
        previous_user_id = session[:user_id]
        stop_impersonation
        clear_current_order

        flash[:success] = t('workarea.admin.users.flash_messages.stopped')
        referrer = URI.parse(request.referrer).request_uri rescue nil
        redirect_back_or(referrer.presence || user_path(previous_user_id))
      end
    end
  end
end
