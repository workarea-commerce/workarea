module Workarea
  module Storefront
    class SearchesController < Storefront::ApplicationController
      before_action :cache_page

      def show
        if search_query.blank?
          flash[:error] = t('workarea.storefront.flash_messages.no_search_query')
          redirect_back fallback_location: root_path
          return
        end

        response = Search::StorefrontSearch.new(params.to_unsafe_h).response
        handle_search_response(response)
      end

      private

      def search_query
        QueryString.new(params[:q]).sanitized
      end

      def handle_search_response(response)
        redirect_to response.redirect and return if response.redirect?

        set_search(response)
        status = response.template == 'no_results' ? :not_found : :ok
        render response.template, status: status
      end

      def set_search(response)
        @search = SearchViewModel.new(response, view_model_options)
      end
    end
  end
end
