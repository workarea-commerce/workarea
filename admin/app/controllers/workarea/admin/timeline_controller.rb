module Workarea
  module Admin
    class TimelineController < Admin::ApplicationController
      def show
        model = GlobalID::Locator.locate(params[:id])
        @timeline = TimelineViewModel.new(model)
      end
    end
  end
end
