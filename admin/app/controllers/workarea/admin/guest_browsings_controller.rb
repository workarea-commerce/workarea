module Workarea
  module Admin
    class GuestBrowsingsController < Admin::ApplicationController
      include Storefront::CurrentCheckout

      def create
        admin_browse_as_guest
        clear_current_order

        flash[:success] =
          t('workarea.admin.guest_browsing.flash_messages.started')
        redirect_to storefront.root_path
      end

      def destroy
        stop_admin_guest_browsing
        clear_current_order

        flash[:success] = t('workarea.admin.guest_browsing.flash_messages.stopped')
        redirect_back_or root_path
      end
    end
  end
end
