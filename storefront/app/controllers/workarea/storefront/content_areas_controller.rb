module Workarea
  module Storefront
    class ContentAreasController < Storefront::ApplicationController
      layout 'workarea/storefront/empty'

      before_action :require_login
      before_action :require_admin

      def show
        @content = ContentViewModel.new(Content.find(params[:id]))
        @area_id = params[:area_id]
      end
    end
  end
end
