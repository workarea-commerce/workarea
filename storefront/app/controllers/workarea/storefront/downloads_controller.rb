module Workarea
  module Storefront
    class DownloadsController < Storefront::ApplicationController
      def show
        token = Fulfillment::Token.find(params[:id])
        sku = Fulfillment::Sku.find(token.sku) rescue nil

        if token&.enabled? && sku&.downloadable?
          token.inc(downloads: 1)
          send_file sku.file.file, filename: sku.file_name
        else
          flash[:info] = t('workarea.storefront.flash_messages.download_unavailable')
          redirect_to root_path
        end
      end
    end
  end
end
