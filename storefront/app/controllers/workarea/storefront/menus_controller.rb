module Workarea
  module Storefront
    class MenusController < Storefront::ApplicationController
      before_action :cache_page

      layout :navigation_layout

      def index
        models = Navigation::Menu.all.select(&:active?)
        @menus = MenuViewModel.wrap(models, params)
      end

      def show
        model = Navigation::Menu.find(params[:id])
        @menu = MenuViewModel.wrap(model, params)
      end

      private

      def navigation_layout
        request.xhr? ? false : 'workarea/storefront/navigation'
      end
    end
  end
end
