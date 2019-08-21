module Workarea
  module Admin
    class ActivitiesController < Admin::ApplicationController
      def show
        @activity = ActivityViewModel.new(nil, view_model_options)
      end
    end
  end
end
