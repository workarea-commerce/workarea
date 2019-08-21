module Workarea
  module Admin
    class BookmarksController < Admin::ApplicationController
      def create
        User::AdminBookmark.create!(params[:bookmark].merge(user: current_user))
        flash[:success] = t('workarea.admin.bookmarks.flash_messages.created')
        redirect_back fallback_location: root_path
      end

      def destroy
        User::AdminBookmark.find(params[:id]).destroy
        flash[:success] = t('workarea.admin.bookmarks.flash_messages.destroyed')
        redirect_back fallback_location: root_path
      end
    end
  end
end
