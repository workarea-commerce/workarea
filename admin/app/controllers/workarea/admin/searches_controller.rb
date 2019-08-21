module Workarea
  module Admin
    class SearchesController < Admin::ApplicationController
      def show
        search = Search::AdminSearch.new(params)
        options = view_model_options.merge(show_type: true)
        @search = SearchViewModel.new(search, options)
      end
    end
  end
end
