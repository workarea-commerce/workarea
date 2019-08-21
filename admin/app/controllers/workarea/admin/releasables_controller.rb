module Workarea
  module Admin
    class ReleasablesController < Admin::ApplicationController
      def index
        model = Release.find(params[:release_id])
        self.current_release = model

        @release = ReleaseViewModel.wrap(model, view_model_options)
        search = Search::AdminReleasables.new(params)

        options = view_model_options.merge(show_type: true)
        @search = SearchViewModel.new(search, options)
      end
    end
  end
end
