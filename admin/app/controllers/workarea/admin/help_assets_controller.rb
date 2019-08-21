module Workarea
  module Admin
    class HelpAssetsController < Admin::ApplicationController
      include HelpAuthorization

      def index
        @help_assets =
          Help::Asset
            .desc(:created_at)
            .page(params[:page] || 1)
            .per(Workarea.config.per_page)
      end

      def create
        Help::Asset.create!(params[:help_asset])
        flash[:success] = t('workarea.admin.help_assets.flash_messages.created')
        redirect_back fallback_location: help_assets_path
      end

      def destroy
        Help::Asset.find(params[:id]).destroy
        flash[:success] = t('workarea.admin.help_assets.flash_messages.removed')
        redirect_back fallback_location: help_assets_path
      end
    end
  end
end
