module Workarea
  module Admin
    class GuestBrowsingsController < Admin::ApplicationController
      include Storefront::CurrentCheckout
      required_permissions :people

      def create
        admin_browse_as_guest
        self.current_order = nil

        flash[:success] =
          t('workarea.admin.guest_browsing.flash_messages.started')
        redirect_to storefront.root_path
      end

      def destroy
        stop_admin_guest_browsing
        self.current_order = nil

        flash[:success] = t('workarea.admin.guest_browsing.flash_messages.stopped')
        redirect_to users_path
      end
    end
  end
end
